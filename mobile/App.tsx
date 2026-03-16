import React from 'react';
import { StatusBar } from 'expo-status-bar';
import { NavigationContainer } from '@react-navigation/native';
import { BleProvider } from './src/context/BleContext';
import { AppNavigator } from './src/navigation/AppNavigator';

export default function App() {
  return (
    <BleProvider>
      <NavigationContainer>
        <StatusBar style="light" />
        <AppNavigator />
      </NavigationContainer>
    </BleProvider>
  );
}
