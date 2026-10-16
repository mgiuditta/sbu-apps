import Foundation

/// A fixed Bluetooth state and a fixed set of devices advertising four times a second, for the
/// simulator, screenshots, UI tests and previews. The simulator has no Bluetooth.
final class FixedScanner: BluetoothScanner {
    /// How often each device advertises.
    static let interval = Duration.milliseconds(250)

    /// Earbuds close by, other devices around the room, and three without a name.
    static let demoDevices: [Advertisement] = [
        demo("Buds Pro", rssi: -52, id: 1),
        demo("WH-1000XM5", rssi: -61, id: 2),
        demo(nil, rssi: -64, id: 7, manufacturerData: Data([0x4C, 0x00, 0x07, 0x19])),
        demo("Forerunner 255", rssi: -67, id: 3),
        demo("JBL Flip 6", rssi: -72, id: 4),
        demo("MacBook Air", rssi: -78, id: 5),
        demo(nil, rssi: -83, id: 8),
        demo("Mi Band 8", rssi: -86, id: 6),
        demo(nil, rssi: -94, id: 9),
    ]

    /// The scanner a launch asks for: `-FIXED_SCANNER demo` for the demo devices, `empty` for
    /// none, `fading` for the closest one going silent after two seconds, or a state
    /// such as `-FIXED_SCANNER poweredOff`; `-FASTLANE_SNAPSHOT YES` for the demo devices.
    /// `nil` on a normal launch.
    static func requested(in defaults: UserDefaults) -> FixedScanner? {
        switch defaults.string(forKey: "FIXED_SCANNER") {
        case "demo":
            FixedScanner()
        case "empty":
            FixedScanner(devices: [])
        case "fading":
            FixedScanner(firstFallsSilentAfter: .seconds(2))
        case let name?:
            BluetoothState(rawValue: name).map { FixedScanner(state: $0) }
        case nil:
            defaults.bool(forKey: "FASTLANE_SNAPSHOT") ? FixedScanner() : nil
        }
    }

    let state: BluetoothState
    let devices: [Advertisement]
    /// The first device stops advertising this long after each start: a device switched off.
    let firstFallsSilentAfter: Duration?

    private var continuation: AsyncStream<ScanEvent>.Continuation?
    private var advertising: Task<Void, Never>?
    private(set) var mode = ScanMode.foreground

    init(state: BluetoothState = .ready, devices: [Advertisement] = FixedScanner.demoDevices, firstFallsSilentAfter: Duration? = nil) {
        self.state = state
        self.devices = devices
        self.firstFallsSilentAfter = firstFallsSilentAfter
    }

    func events() -> AsyncStream<ScanEvent> {
        let (stream, continuation) = AsyncStream.makeStream(of: ScanEvent.self, bufferingPolicy: .bufferingNewest(512))
        self.continuation = continuation
        continuation.yield(.state(state))
        restart()
        return stream
    }

    func listen(_ mode: ScanMode) {
        self.mode = mode
        restart()
    }

    func restart() {
        advertising?.cancel()
        guard state == .ready, let continuation else { return }
        // In the background only the devices advertising one of the services are heard.
        let devices: [Advertisement] = switch mode {
        case .foreground: devices
        case .background(let services): devices.filter { !Set($0.serviceUUIDs).isDisjoint(with: services) }
        case .paused: []
        }
        let silentAt = firstFallsSilentAfter.map { ContinuousClock.now + $0 }
        advertising = Task {
            while !Task.isCancelled {
                let now = Date.now
                let isFirstSilent = silentAt.map { ContinuousClock.now >= $0 } ?? false
                for (index, device) in devices.enumerated() where !(index == 0 && isFirstSilent) {
                    continuation.yield(.advertisement(device.heard(at: now)))
                }
                try? await Task.sleep(for: Self.interval)
            }
        }
    }

    func stop() {
        advertising?.cancel()
        advertising = nil
        continuation?.finish()
        continuation = nil
    }

    /// A fixed identifier, so a UI test finds the same device on every launch.
    private static func demoID(_ number: Int) -> UUID {
        let digits = String(number)
        let suffix = String(repeating: "0", count: max(0, 12 - digits.count)) + digits
        return UUID(uuidString: "00000000-0000-4000-8000-" + suffix) ?? UUID()
    }

    private static func demo(_ name: String?, rssi: Int, id: Int, manufacturerData: Data? = nil) -> Advertisement {
        Advertisement(
            id: demoID(id),
            name: name,
            rssi: rssi,
            manufacturerData: manufacturerData,
            date: .distantPast
        )
    }
}
