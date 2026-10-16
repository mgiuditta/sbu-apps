import CoreBluetooth

/// Listens to Bluetooth Low Energy advertisements with Core Bluetooth.
///
/// It only listens: it never connects to a device, and nothing it hears leaves the iPhone.
/// In the foreground it hears every device, with duplicates, so the signal keeps updating. In the
/// background iOS allows only a scan for service UUIDs, reports each device once per scan and
/// less often: so after each report the scan starts again, to hear the device the next time it
/// advertises. With a restore identifier, iOS relaunches the app in the background for those
/// devices; a force-quit stops all of it until the app is opened again.
final class CoreBluetoothScanner: NSObject, BluetoothScanner, CBCentralManagerDelegate {
    /// Lets iOS relaunch the app in the background for the devices it was listening for.
    static let restoreIdentifier = "dev.sbu.find.central"

    private var manager: CBCentralManager?
    private var continuation: AsyncStream<ScanEvent>.Continuation?
    /// How the model asked to listen; `nil` until it does.
    private var mode: ScanMode?
    /// The services iOS was scanning for when it relaunched the app in the background.
    private var restoredServices: [String] = []

    func events() -> AsyncStream<ScanEvent> {
        let (stream, continuation) = AsyncStream.makeStream(of: ScanEvent.self, bufferingPolicy: .bufferingNewest(512))
        self.continuation = continuation
        if let manager {
            stateChanged(manager)
        } else {
            // On the main queue, so the delegate runs on the main actor. No system alert when
            // Bluetooth is off: the screen says it and how to turn it on.
            manager = CBCentralManager(delegate: self, queue: nil, options: [
                CBCentralManagerOptionShowPowerAlertKey: false,
                CBCentralManagerOptionRestoreIdentifierKey: Self.restoreIdentifier,
            ])
        }
        return stream
    }

    func listen(_ mode: ScanMode) {
        guard mode != self.mode else { return }
        self.mode = mode
        restart()
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
        scan(with: manager)
    }

    private func scan(with manager: CBCentralManager) {
        switch mode {
        case nil:
            // Not told yet, as when the saved devices cannot be read before the first unlock:
            // go on with the scan iOS restored, so it keeps relaunching the app for them.
            if !restoredServices.isEmpty {
                manager.scanForPeripherals(withServices: restoredServices.map(CBUUID.init(string:)), options: nil)
            }
        case .foreground:
            // Duplicates on, so every advertisement updates the signal, not only the first.
            manager.scanForPeripherals(withServices: nil, options: [CBCentralManagerScanOptionAllowDuplicatesKey: true])
        case .background(let services):
            manager.scanForPeripherals(withServices: services.map(CBUUID.init(string:)), options: nil)
        case .paused:
            manager.stopScan()
        }
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

    nonisolated func centralManager(_ central: CBCentralManager, willRestoreState dict: [String: Any]) {
        // Relaunched in the background for a saved device: the model sets the mode from its
        // saved devices; until it can, the scan goes on for the services restored here.
        let services = (dict[CBCentralManagerRestoredStateScanServicesKey] as? [CBUUID] ?? []).map(\.uuidString)
        MainActor.assumeIsolated {
            restoredServices = services
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
            // In the background each scan reports a device once: start again for the next time.
            if case .background = mode, let manager {
                manager.stopScan()
                scan(with: manager)
            }
        }
    }
}
