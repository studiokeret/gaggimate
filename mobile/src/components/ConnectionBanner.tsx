import React from 'react';
import { View, Text, StyleSheet } from 'react-native';

interface ConnectionBannerProps {
  status: 'disconnected' | 'connecting' | 'connected';
}

export function ConnectionBanner({ status }: ConnectionBannerProps) {
  const isConnected = status === 'connected';
  const isConnecting = status === 'connecting';

  return (
    <View style={[styles.banner, isConnected ? styles.connected : styles.disconnected]}>
      <View style={[styles.dot, isConnected ? styles.dotGreen : styles.dotRed]} />
      <Text style={styles.text}>
        {isConnected ? 'Connected via Bluetooth' : isConnecting ? 'Connecting...' : 'Not connected'}
      </Text>
    </View>
  );
}

const styles = StyleSheet.create({
  banner: {
    flexDirection: 'row',
    alignItems: 'center',
    paddingHorizontal: 12,
    paddingVertical: 10,
    borderRadius: 10,
    marginBottom: 12,
  },
  connected: {
    backgroundColor: 'rgba(34, 197, 94, 0.1)',
  },
  disconnected: {
    backgroundColor: 'rgba(239, 68, 68, 0.1)',
  },
  dot: {
    width: 8,
    height: 8,
    borderRadius: 4,
    marginRight: 8,
  },
  dotGreen: {
    backgroundColor: '#22c55e',
  },
  dotRed: {
    backgroundColor: '#ef4444',
  },
  text: {
    color: '#aaa',
    fontSize: 13,
  },
});
