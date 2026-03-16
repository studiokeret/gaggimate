import React from 'react';
import { View, Text, StyleSheet, ScrollView } from 'react-native';
import { useBle } from '../context/BleContext';
import { ConnectionBanner } from '../components/ConnectionBanner';
import { StatCard } from '../components/StatCard';

export function DashboardScreen() {
  const { connectionStatus, sensorData, weight, brewActive, steamActive, errorCode } = useBle();

  const tempColor =
    sensorData.temperature < 80
      ? '#3b82f6'
      : sensorData.temperature < 100
        ? '#22c55e'
        : '#ef4444';

  return (
    <ScrollView style={styles.container} contentContainerStyle={styles.content}>
      <ConnectionBanner status={connectionStatus} />

      {/* Temperature */}
      <View style={styles.tempContainer}>
        <Text style={[styles.tempValue, { color: tempColor }]}>
          {sensorData.temperature.toFixed(1)}
        </Text>
        <Text style={styles.tempUnit}>°C</Text>
        {/* Mode badges */}
        <View style={styles.modeBadges}>
          {brewActive && (
            <View style={[styles.badge, styles.badgeBrew]}>
              <Text style={styles.badgeText}>BREW</Text>
            </View>
          )}
          {steamActive && (
            <View style={[styles.badge, styles.badgeSteam]}>
              <Text style={styles.badgeText}>STEAM</Text>
            </View>
          )}
          {!brewActive && !steamActive && (
            <View style={[styles.badge, styles.badgeStandby]}>
              <Text style={styles.badgeText}>STANDBY</Text>
            </View>
          )}
        </View>
      </View>

      {/* Stats Grid */}
      <View style={styles.statsRow}>
        <StatCard
          label="Pressure"
          value={sensorData.pressure.toFixed(1)}
          unit="bar"
        />
        <StatCard
          label="Flow"
          value={sensorData.puckFlow.toFixed(1)}
          unit="ml/s"
        />
        <StatCard
          label="Weight"
          value={weight.toFixed(1)}
          unit="g"
        />
      </View>

      <View style={styles.statsRow}>
        <StatCard
          label="Pump Flow"
          value={sensorData.pumpFlow.toFixed(1)}
          unit="ml/s"
        />
        <StatCard
          label="Resistance"
          value={sensorData.puckResistance.toFixed(1)}
          unit=""
        />
      </View>

      {/* Error */}
      {errorCode !== null && (
        <View style={styles.errorBanner}>
          <Text style={styles.errorText}>Error code: {errorCode}</Text>
        </View>
      )}
    </ScrollView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#0A1120',
  },
  content: {
    padding: 16,
  },
  tempContainer: {
    alignItems: 'center',
    paddingVertical: 32,
    backgroundColor: '#1a2332',
    borderRadius: 16,
    marginBottom: 16,
  },
  tempValue: {
    fontSize: 72,
    fontWeight: '700',
    fontVariant: ['tabular-nums'],
  },
  tempUnit: {
    fontSize: 24,
    color: '#888',
    marginTop: -8,
  },
  modeBadges: {
    flexDirection: 'row',
    gap: 8,
    marginTop: 12,
  },
  badge: {
    paddingHorizontal: 12,
    paddingVertical: 4,
    borderRadius: 8,
  },
  badgeBrew: {
    backgroundColor: 'rgba(139, 94, 60, 0.3)',
  },
  badgeSteam: {
    backgroundColor: 'rgba(59, 130, 246, 0.3)',
  },
  badgeStandby: {
    backgroundColor: 'rgba(100, 100, 100, 0.3)',
  },
  badgeText: {
    color: '#fff',
    fontSize: 13,
    fontWeight: '700',
    letterSpacing: 1,
  },
  statsRow: {
    flexDirection: 'row',
    gap: 8,
    marginBottom: 8,
  },
  errorBanner: {
    backgroundColor: 'rgba(239, 68, 68, 0.2)',
    padding: 12,
    borderRadius: 12,
    marginTop: 8,
  },
  errorText: {
    color: '#ef4444',
    textAlign: 'center',
    fontWeight: '600',
  },
});
