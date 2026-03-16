import React from 'react';
import { View, Text, TouchableOpacity, StyleSheet } from 'react-native';
import { useBle } from '../context/BleContext';
import { ConnectionBanner } from '../components/ConnectionBanner';

export function ControlScreen() {
  const {
    connectionStatus,
    connectedDeviceId,
    brewActive,
    steamActive,
    sensorData,
    sendBrewStart,
    sendBrewStop,
    sendOutputControl,
  } = useBle();

  const isConnected = connectionStatus === 'connected';

  return (
    <View style={styles.container}>
      <ConnectionBanner status={connectionStatus} />

      <View style={styles.content}>
        {/* Brew Button */}
        <TouchableOpacity
          style={[
            styles.brewButton,
            brewActive ? styles.brewButtonActive : styles.brewButtonIdle,
            !isConnected && styles.buttonDisabled,
          ]}
          onPress={brewActive ? sendBrewStop : sendBrewStart}
          disabled={!isConnected}
        >
          <Text style={styles.brewButtonIcon}>{brewActive ? '⬛' : '☕'}</Text>
          <Text style={styles.brewButtonText}>
            {brewActive ? 'Stop Brew' : 'Start Brew'}
          </Text>
          <Text style={styles.brewButtonSub}>
            {brewActive
              ? `${sensorData.pressure.toFixed(1)} bar • ${sensorData.puckFlow.toFixed(1)} ml/s`
              : `${sensorData.temperature.toFixed(1)}°C`}
          </Text>
        </TouchableOpacity>

        {/* Quick Actions */}
        <View style={styles.actionsRow}>
          <TouchableOpacity
            style={[styles.actionBtn, !isConnected && styles.buttonDisabled]}
            onPress={() => sendOutputControl(0, 0, 0)}
            disabled={!isConnected}
          >
            <Text style={styles.actionIcon}>⏹</Text>
            <Text style={styles.actionText}>All Off</Text>
          </TouchableOpacity>

          <TouchableOpacity
            style={[styles.actionBtn, !isConnected && styles.buttonDisabled]}
            onPress={() => sendOutputControl(1, 0, 100)}
            disabled={!isConnected}
          >
            <Text style={styles.actionIcon}>💧</Text>
            <Text style={styles.actionText}>Valve Open</Text>
          </TouchableOpacity>
        </View>

        {!isConnected && (
          <Text style={styles.hint}>
            Connect to your GaggiMate on the Connect tab to use controls
          </Text>
        )}
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#0A1120',
  },
  content: {
    flex: 1,
    padding: 16,
    justifyContent: 'center',
  },
  brewButton: {
    alignItems: 'center',
    justifyContent: 'center',
    paddingVertical: 48,
    borderRadius: 24,
    marginBottom: 24,
  },
  brewButtonIdle: {
    backgroundColor: '#8B5E3C',
  },
  brewButtonActive: {
    backgroundColor: '#dc2626',
  },
  buttonDisabled: {
    opacity: 0.4,
  },
  brewButtonIcon: {
    fontSize: 48,
    marginBottom: 8,
  },
  brewButtonText: {
    color: '#fff',
    fontSize: 24,
    fontWeight: '700',
  },
  brewButtonSub: {
    color: 'rgba(255,255,255,0.7)',
    fontSize: 14,
    marginTop: 4,
  },
  actionsRow: {
    flexDirection: 'row',
    gap: 12,
  },
  actionBtn: {
    flex: 1,
    backgroundColor: '#1a2332',
    paddingVertical: 20,
    borderRadius: 16,
    alignItems: 'center',
  },
  actionIcon: {
    fontSize: 24,
    marginBottom: 4,
  },
  actionText: {
    color: '#fff',
    fontSize: 14,
    fontWeight: '600',
  },
  hint: {
    color: '#666',
    textAlign: 'center',
    marginTop: 32,
    fontSize: 14,
  },
});
