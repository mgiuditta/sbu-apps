/** Characters the Wi-Fi QR format reserves, escaped with a backslash. */
const reserved = /([\\;,:"])/g;

/**
 * The text of a Wi-Fi QR code, as iOS and Android cameras read it: `WIFI:T:WPA;S:name;P:secret;;`.
 * `security` is `WPA`, `WEP` or `nopass`; an open network carries no password.
 */
export function wifiPayload(ssid: string, password: string, security: string): string {
  const escape = (value: string) => value.replace(reserved, '\\$1');
  const secret = security === 'nopass' ? '' : `P:${escape(password)};`;
  return `WIFI:T:${security};S:${escape(ssid)};${secret};`;
}
