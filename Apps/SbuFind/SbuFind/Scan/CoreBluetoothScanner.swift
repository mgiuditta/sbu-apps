import CoreBluetooth

/// Listens to Bluetooth Low Energy advertisements with Core Bluetooth while the app is open.
///
/// It only listens: it never connects to a device, and nothing it hears leaves the iPhone or is
/// saved. Creating the manager asks for Bluetooth the first time.
final class CoreBluetoothScanner: NSObject, BluetoothScanner, CBCentralManagerDelegate {
    private var manager: CBCentralManager?
    private var continuation: AsyncStream<ScanEvent>.Continuation?

    func events() -> AsyncStream<ScanEvent> {
        let (stream, continuation) = AsyncStream.makeStream(of: ScanEvent.self, bufferingPolicy: .bufferingNewest(512))
        self.continuation = continuation
        if let manager {
            stateChanged(manager)
        } else {
            // On the main queue, so the delegate runs on the main actor. No system alert when
            // Bluetooth is off: the screen says it and how to turn it on.
            manager = CBCentralManager(delegate: self, queue: nil, options: [CBCentralManagerOptionShowPowerAlertKey: false])
        }
        return stream
    }

    func restart() {
        guard let manager else { return }
        manager.stopScan()
        stateChanged(manager)
    }

    func stop() {
        manager?.stopScan()
        continuation?.finish()
        continuation = nil
    }

    private func stateChanged(_ manager: CBCentralManager) {
        let state = BluetoothState(managerState: manager.state, authorization: CBCentralManager.authorization)
        continuation?.yield(.state(state))
        guard state == .ready, continuation != nil else { return }
        // Duplicates on, so every advertisement updates the signal, not only the first.
        manager.scanForPeripherals(withServices: nil, options: [CBCentralManagerScanOptionAllowDuplicatesKey: true])
    }

    // The manager runs on the main queue, so it calls its delegate on the main thread.

    nonisolated func centralManagerDidUpdateState(_ central: CBCentralManager) {
        MainActor.assumeIsolated {
            // The one manager this scanner made: the parameter is not sendable across isolation.
            if let manager {
                stateChanged(manager)
            }
        }
    }

    nonisolated func centralManager(
        _ central: CBCentralManager,
        didDiscover peripheral: CBPeripheral,
        advertisementData: [String: Any],
        rssi RSSI: NSNumber
    ) {
        let advertisement = Advertisement(
            id: peripheral.identifier,
            name: advertisementData[CBAdvertisementDataLocalNameKey] as? String ?? peripheral.name,
            rssi: RSSI.intValue,
            manufacturerData: advertisementData[CBAdvertisementDataManufacturerDataKey] as? Data,
            serviceUUIDs: (advertisementData[CBAdvertisementDataServiceUUIDsKey] as? [CBUUID] ?? []).map(\.uuidString),
            date: .now
        )
        MainActor.assumeIsolated {
            _ = continuation?.yield(.advertisement(advertisement))
        }
    }
}
