// BLE UUIDs matching lib/NimBLEComm/src/NimBLEComm.h
export const DEVICE_NAME = 'GPBLS';
export const SERVICE_UUID = 'e75bc5b6-ff6e-4337-9d31-0c128f2e6e68';

// Notify characteristics (ESP32 → Phone)
export const SENSOR_DATA_UUID = '62b69e72-ac19-4d4b-bd53-2edd65330c93';
export const BREW_BTN_UUID = 'a29eb137-b33e-45a4-b1fc-15eb04e8ab39';
export const STEAM_BTN_UUID = '53750675-4839-421e-971e-cc6823507d8e';
export const VOLUMETRIC_UUID = 'b0080557-3865-4a9c-be37-492d77ee5951';
export const ERROR_UUID = 'd6676ec7-820c-41de-820d-95620749003b';
export const AUTOTUNE_RESULT_UUID = '7f61607a-2817-4354-9b94-d49c057fc879';
export const TOF_UUID = '7282c525-21a0-416a-880d-21fe98602533';

// Write characteristics (Phone → ESP32)
export const OUTPUT_CONTROL_UUID = '77fbb08f-c29c-4f2e-8e1d-ed0a9afa5e1a';
export const ALT_CONTROL_UUID = 'cca5a577-ec67-4499-8ccb-654f1312db1d';
export const PING_UUID = '9731755e-29ce-41a8-91d9-7a244f49859b';
export const PID_CONTROL_UUID = 'd448c469-3e1d-4105-b5b8-75bf7d492fad';
export const AUTOTUNE_UUID = 'd54df381-69b6-4531-b1cc-dde7766bbaf4';
export const PRESSURE_SCALE_UUID = '3aa65ab6-2dda-4c95-9cf3-58b2a0480623';
export const VOLUMETRIC_TARE_UUID = 'a8bd52e0-77c3-412c-847c-4e802c3982f9';
export const LED_CONTROL_UUID = '37804a2b-49ab-4500-8582-db4279fc8573';
export const PUMP_MODEL_COEFFS_UUID = 'e448c469-3e1d-4105-b5b8-75bf7d492fae';

// Read characteristics
export const INFO_UUID = 'f8d7203b-e00c-48e2-83ba-37ff49cdba74';
