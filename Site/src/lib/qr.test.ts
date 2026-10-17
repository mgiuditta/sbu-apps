// node --test src/lib/qr.test.ts
import assert from 'node:assert/strict';
import { test } from 'node:test';
import { wifiPayload } from './qr.ts';

test('WPA network', () => {
  assert.equal(wifiPayload('Casa', 'segreta', 'WPA'), 'WIFI:T:WPA;S:Casa;P:segreta;;');
});

test('reserved characters are escaped', () => {
  assert.equal(wifiPayload('Bar; "Da Mario"', 'a:b,c\\d', 'WPA'), 'WIFI:T:WPA;S:Bar\\; \\"Da Mario\\";P:a\\:b\\,c\\\\d;;');
});

test('open network has no password', () => {
  assert.equal(wifiPayload('Ospiti', 'ignored', 'nopass'), 'WIFI:T:nopass;S:Ospiti;;');
});
