import Foundation
import Observation

/// The live scan: the Bluetooth state and the devices heard in the last seconds.
///
/// Advertisements arrive many times a second; the list on screen is refreshed twice a second,
/// so rows do not jump at every packet. Nothing is saved but the settings.
@Observable
final class ScanModel {
    /// How often the list on screen catches up with what was heard.
    static let refreshInterval = Duration.milliseconds(500)
    private static let showsUnnamedKey = "showsUnnamed"

    private(set) var state = BluetoothState.starting
    /// The devices on screen, strongest signal first.
    private(set) var devices: [NearbyDevice] = []
    /// Devices heard but left out because they have no name.
    private(set) var hiddenUnnamedCount = 0
    /// The device on the finder, kept after it falls silent so the finder can say for how long.
    private(set) var tracked: TrackedDevice?

    /// Off by default: most devices without a name are phones and computers around you, not what you lost.
    var showsUnnamed: Bool {
        didSet {
            defaults.set(showsUnnamed, forKey: Self.showsUnnamedKey)
            publish(at: .now)
        }
    }

    @ObservationIgnored private var roster = DeviceRoster()
    @ObservationIgnored private let scanner: any BluetoothScanner
    @ObservationIgnored private let defaults: UserDefaults
    @ObservationIgnored private var trackedID: UUID?
    @ObservationIgnored private var warmthTracker = WarmthTracker()

    /// - Parameter scanner: Core Bluetooth unless a launch argument asks for the fixed scanner.
    init(scanner: (any BluetoothScanner)? = nil, defaults: UserDefaults = .standard) {
        self.scanner = scanner ?? FixedScanner.requested(in: defaults) ?? CoreBluetoothScanner()
        self.defaults = defaults
        showsUnnamed = defaults.bool(forKey: Self.showsUnnamedKey)
    }

    /// Scans until the calling task is cancelled, as when the app goes to the background.
    func run() async {
        let events = scanner.events()
        await withDiscardingTaskGroup { group in
            group.addTask {
                await self.refreshUntilCancelled()
            }
            for await event in events {
                handle(event)
            }
            group.cancelAll()
        }
        scanner.stop()
    }

    func handle(_ event: ScanEvent) {
        switch event {
        case .state(let newState):
            state = newState
            if newState != .ready {
                roster.removeAll()
                publish(at: .now)
            }
        case .advertisement(let advertisement):
            roster.record(advertisement)
        }
    }

    /// Drops the devices gone silent and shows what was heard since the last refresh.
    func refresh(at now: Date) {
        roster.removeStale(at: now)
        publish(at: now)
    }

    /// Cerca di nuovo: forgets every device and listens from scratch.
    func rescan() {
        roster.removeAll()
        publish(at: .now)
        scanner.restart()
    }

    /// The finder opened on this device: from now on `tracked` follows it.
    func track(_ id: UUID, at now: Date = .now) {
        trackedID = id
        tracked = nil
        warmthTracker.reset()
        updateTracked(at: now)
    }

    /// The finder closed.
    func stopTracking() {
        trackedID = nil
        tracked = nil
        warmthTracker.reset()
    }

    private func refreshUntilCancelled() async {
        // A cancelled sleep throws: stop there, without one last refresh.
        while (try? await Task.sleep(for: Self.refreshInterval)) != nil {
            refresh(at: .now)
        }
    }

    private func publish(at now: Date) {
        updateTracked(at: now)
        let listed = roster.devices(includingUnnamed: showsUnnamed)
        if listed != devices {
            devices = listed
        }
        let hidden = showsUnnamed ? 0 : roster.unnamedCount
        if hidden != hiddenUnnamedCount {
            hiddenUnnamedCount = hidden
        }
    }

    private func updateTracked(at now: Date) {
        guard let trackedID else { return }
        guard let device = roster.device(id: trackedID) ?? tracked?.device else {
            tracked = nil
            return
        }
        // The word moves only on a new reading; while silent it keeps the last one.
        let isNewReading = device.lastSeen != tracked?.device.lastSeen
        let warmth = isNewReading ? warmthTracker.update(with: device.proximity) : tracked?.warmth ?? device.warmth
        let updated = TrackedDevice(device: device, warmth: warmth, silence: max(0, now.timeIntervalSince(device.lastSeen)))
        if updated != tracked {
            tracked = updated
        }
    }
}
