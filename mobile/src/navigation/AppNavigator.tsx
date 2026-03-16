import React from 'react';
import { createBottomTabNavigator } from '@react-navigation/bottom-tabs';
import { ConnectScreen } from '../screens/ConnectScreen';
import { DashboardScreen } from '../screens/DashboardScreen';
import { ControlScreen } from '../screens/ControlScreen';
import { Text } from 'react-native';

const Tab = createBottomTabNavigator();

function TabIcon({ label, focused }: { label: string; focused: boolean }) {
  const icons: Record<string, string> = {
    Connect: '📡',
    Dashboard: '📊',
    Control: '☕',
  };
  return (
    <Text style={{ fontSize: 20, opacity: focused ? 1 : 0.5 }}>
      {icons[label] || '•'}
    </Text>
  );
}

export function AppNavigator() {
  return (
    <Tab.Navigator
      screenOptions={({ route }) => ({
        headerStyle: { backgroundColor: '#0A1120' },
        headerTintColor: '#fff',
        tabBarStyle: { backgroundColor: '#0A1120', borderTopColor: '#1a2332' },
        tabBarActiveTintColor: '#8B5E3C',
        tabBarInactiveTintColor: '#666',
        tabBarIcon: ({ focused }) => <TabIcon label={route.name} focused={focused} />,
      })}
    >
      <Tab.Screen name="Connect" component={ConnectScreen} />
      <Tab.Screen name="Dashboard" component={DashboardScreen} />
      <Tab.Screen name="Control" component={ControlScreen} />
    </Tab.Navigator>
  );
}
