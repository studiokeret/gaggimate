import React, { createContext, useContext, useState, useRef, useCallback, useEffect } from 'react';
import { Platform, PermissionsAndroid } from 'react-native';
import { Device, Subscription } from 'react-native-ble-plx';
import {
  getManager,
  scanForDevices,
  connectToDevice,
  disconnectDevice,
  subscribeToCharacteristic,
  writeCharacteristic,
} from '../services/bleManager';
import {
  SENSOR_DATA_UUID,
  BREW_BTN_UUID,
  STEAM_BTN_UUID,
  VOLUMETRIC_UUID,
  ERROR_UUID,
  OUTPUT_CONTROL_UUID,
  PING_UUID,
} from '../constants/ble';

export interface SensorData {
  temperature: number;
  pressure: number;
  puckFlow: number;
  pumpFlow: number;
  puckResistance: number;
}

export interface BleContextType {
  // Connection
  isScanning: boolean;
  discoveredDevices: Device[];
  connectedDeviceId: string | null;
  connectionStatus: 'disconnected' | 'connecting' | 'connected';

  // Sensor data
  sensorData: SensorData;
  weight: number;
  brewActive: boolean;
  steamActive: boolean;
  errorCode: number | null;

  // Actions
  startScan: () => void;
  stopScan: () => void;
  connect: (deviceId: string) => Promise<void>;
  disconnect: () => Promise<void>;
  sendBrewStart: () => Promise<void>;
  sendBrewStop: () => Promise<void>;
  sendOutputControl: (valve: number, pump: number, boiler: number) => Promise<void>;
}

const defaultSensorData: SensorData = {
  temperature: 0,
  pressure: 0,
  puckFlow: 0,
  pumpFlow: 0,
  puckResistance: 0,
};

const BleContext = createContext<BleContextType | null>(null);

export function useBle(): BleContextType {
  const ctx = useContext(BleContext);
  if (!ctx) throw new Error('useBle must be used within BleProvider');
  return ctx;
}

export function BleProvider({ children }: { children: React.ReactNode }) {
  const [isScanning, setIsScanning] = useState(false);
  const [discoveredDevices, setDiscoveredDevices] = useState<Device[]>([]);
  const [connectedDeviceId, setConnectedDeviceId] = useState<string | null>(null);
  const [connectionStatus, setConnectionStatus] = useState<'disconnected' | 'connecting' | 'connected'>('disconnected');
  const [sensorData, setSensorData] = useState<SensorData>(defaultSensorData);
  const [weight, setWeight] = useState(0);
  const [brewActive, setBrewActive] = useState(false);
  const [steamActive, setSteamActive] = useState(false);
  const [errorCode, setErrorCode] = useState<number | null>(null);

  const subscriptionsRef = useRef<Subscription[]>([]);
  const pingIntervalRef = useRef<ReturnType<typeof setInterval> | null>(null);
  const stopScanRef = useRef<(() => void) | null>(null);

  // Request Android BLE permissions
  const requestPermissions = useCallback(async () => {
    if (Platform.OS === 'android') {
      const apiLevel = Platform.Version;
      if (apiLevel >= 31) {
        const result = await PermissionsAndroid.requestMultiple([
          PermissionsAndroid.PERMISSIONS.BLUETOOTH_SCAN,
          PermissionsAndroid.PERMISSIONS.BLUETOOTH_CONNECT,
        ]);
        return Object.values(result).every((v) => v === 'granted');
      } else {
        const result = await PermissionsAndroid.request(
          PermissionsAndroid.PERMISSIONS.ACCESS_FINE_LOCATION,
        );
        return result === 'granted';
      }
    }
    return true;
  }, []);

  const startScan = useCallback(async () => {
    const granted = await requestPermissions();
    if (!granted) return;

    setDiscoveredDevices([]);
    setIsScanning(true);

    const seenIds = new Set<string>();
    const stop = scanForDevices((device) => {
      if (!seenIds.has(device.id)) {
        seenIds.add(device.id);
        setDiscoveredDevices((prev) => [...prev, device]);
      }
    });
    stopScanRef.current = stop;

    // Auto-stop after 10 seconds
    setTimeout(() => {
      stop();
      setIsScanning(false);
      stopScanRef.current = null;
    }, 10000);
  }, [requestPermissions]);

  const stopScan = useCallback(() => {
    stopScanRef.current?.();
    stopScanRef.current = null;
    setIsScanning(false);
  }, []);

  const cleanupConnection = useCallback(() => {
    subscriptionsRef.current.forEach((sub) => sub.remove());
    subscriptionsRef.current = [];
    if (pingIntervalRef.current) {
      clearInterval(pingIntervalRef.current);
      pingIntervalRef.current = null;
    }
  }, []);

  const connect = useCallback(async (deviceId: string) => {
    stopScan();
    setConnectionStatus('connecting');

    try {
      const device = await connectToDevice(deviceId);
      setConnectedDeviceId(device.id);
      setConnectionStatus('connected');

      // Subscribe to notifications
      const subs: Subscription[] = [];

      subs.push(
        subscribeToCharacteristic(device.id, SENSOR_DATA_UUID, (value) => {
          const parts = value.split(',').map(Number);
          if (parts.length >= 5) {
            setSensorData({
              temperature: parts[0],
              pressure: parts[1],
              puckFlow: parts[2],
              pumpFlow: parts[3],
              puckResistance: parts[4],
            });
          }
        }),
      );

      subs.push(
        subscribeToCharacteristic(device.id, BREW_BTN_UUID, (value) => {
          setBrewActive(value.trim() === '1');
        }),
      );

      subs.push(
        subscribeToCharacteristic(device.id, STEAM_BTN_UUID, (value) => {
          setSteamActive(value.trim() === '1');
        }),
      );

      subs.push(
        subscribeToCharacteristic(device.id, VOLUMETRIC_UUID, (value) => {
          setWeight(parseFloat(value) || 0);
        }),
      );

      subs.push(
        subscribeToCharacteristic(device.id, ERROR_UUID, (value) => {
          const code = parseInt(value, 10);
          setErrorCode(code === 0 ? null : code);
        }),
      );

      subscriptionsRef.current = subs;

      // Start ping keepalive every 3 seconds
      pingIntervalRef.current = setInterval(() => {
        writeCharacteristic(device.id, PING_UUID, '1').catch(() => {});
      }, 3000);

      // Monitor disconnection
      getManager().onDeviceDisconnected(device.id, () => {
        cleanupConnection();
        setConnectedDeviceId(null);
        setConnectionStatus('disconnected');
        setSensorData(defaultSensorData);
        setBrewActive(false);
        setSteamActive(false);
      });
    } catch (error) {
      console.warn('BLE connect error:', error);
      setConnectionStatus('disconnected');
      setConnectedDeviceId(null);
    }
  }, [stopScan, cleanupConnection]);

  const disconnect = useCallback(async () => {
    if (connectedDeviceId) {
      cleanupConnection();
      await disconnectDevice(connectedDeviceId).catch(() => {});
      setConnectedDeviceId(null);
      setConnectionStatus('disconnected');
      setSensorData(defaultSensorData);
    }
  }, [connectedDeviceId, cleanupConnection]);

  const sendOutputControl = useCallback(
    async (valve: number, pump: number, boiler: number) => {
      if (!connectedDeviceId) return;
      const value = `0,${valve},${pump},${boiler}`;
      await writeCharacteristic(connectedDeviceId, OUTPUT_CONTROL_UUID, value);
    },
    [connectedDeviceId],
  );

  const sendBrewStart = useCallback(async () => {
    await sendOutputControl(1, 100, 100);
  }, [sendOutputControl]);

  const sendBrewStop = useCallback(async () => {
    await sendOutputControl(0, 0, 0);
  }, [sendOutputControl]);

  // Cleanup on unmount
  useEffect(() => {
    return () => {
      cleanupConnection();
    };
  }, [cleanupConnection]);

  return (
    <BleContext.Provider
      value={{
        isScanning,
        discoveredDevices,
        connectedDeviceId,
        connectionStatus,
        sensorData,
        weight,
        brewActive,
        steamActive,
        errorCode,
        startScan,
        stopScan,
        connect,
        disconnect,
        sendBrewStart,
        sendBrewStop,
        sendOutputControl,
      }}
    >
      {children}
    </BleContext.Provider>
  );
}
