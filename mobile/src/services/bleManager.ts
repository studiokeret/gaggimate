import { BleManager, Device, Subscription } from 'react-native-ble-plx';
import { Buffer } from 'buffer';
import { SERVICE_UUID } from '../constants/ble';

// Singleton BLE manager instance
const manager = new BleManager();

export function getManager(): BleManager {
  return manager;
}

export function scanForDevices(
  onDeviceFound: (device: Device) => void,
): () => void {
  manager.startDeviceScan([SERVICE_UUID], null, (error, device) => {
    if (error) {
      console.warn('BLE scan error:', error.message);
      return;
    }
    if (device) {
      onDeviceFound(device);
    }
  });

  return () => manager.stopDeviceScan();
}

export async function connectToDevice(deviceId: string): Promise<Device> {
  const device = await manager.connectToDevice(deviceId);
  await device.discoverAllServicesAndCharacteristics();
  return device;
}

export async function disconnectDevice(deviceId: string): Promise<void> {
  await manager.cancelDeviceConnection(deviceId);
}

export function subscribeToCharacteristic(
  deviceId: string,
  characteristicUUID: string,
  onValue: (value: string) => void,
): Subscription {
  return manager.monitorCharacteristicForDevice(
    deviceId,
    SERVICE_UUID,
    characteristicUUID,
    (error, characteristic) => {
      if (error) {
        console.warn(`BLE notify error [${characteristicUUID}]:`, error.message);
        return;
      }
      if (characteristic?.value) {
        const decoded = Buffer.from(characteristic.value, 'base64').toString('utf-8');
        onValue(decoded);
      }
    },
  );
}

export async function writeCharacteristic(
  deviceId: string,
  characteristicUUID: string,
  value: string,
): Promise<void> {
  const encoded = Buffer.from(value, 'utf-8').toString('base64');
  await manager.writeCharacteristicWithoutResponseForDevice(
    deviceId,
    SERVICE_UUID,
    characteristicUUID,
    encoded,
  );
}
