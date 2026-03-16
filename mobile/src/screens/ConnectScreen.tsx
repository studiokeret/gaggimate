import React from 'react';
import {
  View,
  Text,
  FlatList,
  TouchableOpacity,
  ActivityIndicator,
  StyleSheet,
} from 'react-native';
import { useBle } from '../context/BleContext';

export function ConnectScreen() {
  const {
    isScanning,
    discoveredDevices,
    connectedDeviceId,
    connectionStatus,
    startScan,
    stopScan,
    connect,
    disconnect,
  } = useBle();

  return (
    <View style={styles.container}>
      {/* Connection Status */}
      <View
        style={[
          styles.statusBar,
          connectionStatus === 'connected' ? styles.statusConnected : styles.statusDisconnected,
        ]}
      >
        <Text style={styles.statusText}>
          {connectionStatus === 'connected'
            ? `Connected to ${connectedDeviceId?.slice(0, 8)}...`
            : connectionStatus === 'connecting'
              ? 'Connecting...'
              : 'Not connected'}
        </Text>
        {connectionStatus === 'connected' && (
          <TouchableOpacity onPress={disconnect} style={styles.disconnectBtn}>
            <Text style={styles.disconnectBtnText}>Disconnect</Text>
          </TouchableOpacity>
        )}
      </View>

      {/* Scan Button */}
      <TouchableOpacity
        style={[styles.scanBtn, isScanning && styles.scanBtnActive]}
        onPress={isScanning ? stopScan : startScan}
        disabled={connectionStatus === 'connected'}
      >
        {isScanning ? (
          <View style={styles.scanBtnContent}>
            <ActivityIndicator color="#fff" size="small" />
            <Text style={styles.scanBtnText}>Scanning...</Text>
          </View>
        ) : (
          <Text style={styles.scanBtnText}>
            {connectionStatus === 'connected' ? 'Connected' : 'Scan for GaggiMate'}
          </Text>
        )}
      </TouchableOpacity>

      {/* Device List */}
      <FlatList
        data={discoveredDevices}
        keyExtractor={(item) => item.id}
        contentContainerStyle={styles.list}
        ListEmptyComponent={
          <Text style={styles.emptyText}>
            {isScanning
              ? 'Searching for GaggiMate devices...'
              : 'Tap "Scan" to find your GaggiMate'}
          </Text>
        }
        renderItem={({ item }) => (
          <TouchableOpacity
            style={styles.deviceCard}
            onPress={() => connect(item.id)}
            disabled={connectionStatus !== 'disconnected'}
          >
            <View>
              <Text style={styles.deviceName}>{item.name || 'Unknown Device'}</Text>
              <Text style={styles.deviceId}>{item.id}</Text>
            </View>
            <View style={styles.rssiContainer}>
              <Text style={styles.rssi}>{item.rssi} dBm</Text>
            </View>
          </TouchableOpacity>
        )}
      />
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#0A1120',
  },
  statusBar: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    paddingHorizontal: 16,
    paddingVertical: 12,
    marginHorizontal: 16,
    marginTop: 16,
    borderRadius: 12,
  },
  statusConnected: {
    backgroundColor: 'rgba(34, 197, 94, 0.15)',
  },
  statusDisconnected: {
    backgroundColor: 'rgba(239, 68, 68, 0.15)',
  },
  statusText: {
    color: '#fff',
    fontSize: 14,
  },
  disconnectBtn: {
    paddingHorizontal: 12,
    paddingVertical: 6,
    borderRadius: 8,
    backgroundColor: 'rgba(239, 68, 68, 0.3)',
  },
  disconnectBtnText: {
    color: '#ef4444',
    fontSize: 13,
    fontWeight: '600',
  },
  scanBtn: {
    backgroundColor: '#8B5E3C',
    marginHorizontal: 16,
    marginTop: 16,
    paddingVertical: 16,
    borderRadius: 12,
    alignItems: 'center',
  },
  scanBtnActive: {
    backgroundColor: '#6B4226',
  },
  scanBtnContent: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 8,
  },
  scanBtnText: {
    color: '#fff',
    fontSize: 16,
    fontWeight: '600',
  },
  list: {
    padding: 16,
  },
  emptyText: {
    color: '#666',
    textAlign: 'center',
    marginTop: 32,
    fontSize: 15,
  },
  deviceCard: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    backgroundColor: '#1a2332',
    padding: 16,
    borderRadius: 12,
    marginBottom: 8,
  },
  deviceName: {
    color: '#fff',
    fontSize: 16,
    fontWeight: '600',
  },
  deviceId: {
    color: '#666',
    fontSize: 12,
    marginTop: 4,
  },
  rssiContainer: {
    backgroundColor: '#0A1120',
    paddingHorizontal: 10,
    paddingVertical: 4,
    borderRadius: 8,
  },
  rssi: {
    color: '#888',
    fontSize: 12,
  },
});
