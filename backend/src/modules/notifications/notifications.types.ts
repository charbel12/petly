export type DevicePlatform = 'android' | 'ios' | 'web';

export interface RegisterDeviceTokenDto {
  token: string;
  platform: DevicePlatform;
}

export interface PushPayload {
  title: string;
  body: string;
  data?: Record<string, string>;
}
