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

    /// Off by default: most devices without a name are phones and computers around you, not what you lost.
    var showsUnnamed: Bool {
        didSet {
            defaults.set(showsUnnamed, forKey: Self.showsUnnamedKey)
            publish()
        }
    }

    @ObservationIgnored private var roster = DeviceRoster()
    @ObservationIgnored private let scanner: any BluetoothScanner
    @ObservationIgnored private let defaults: UserDefaults

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
                publish()
            }
        case .advertisement(let advertisement):
            roster.record(advertisement)
        }
    }

    /// Drops the devices gone silent and shows what was heard since the last refresh.
    func refresh(at now: Date) {
        roster.removeStale(at: now)
        publish()
    }

    /// Cerca di nuovo: forgets every device and listens from scratch.
    func rescan() {
        roster.removeAll()
        publish()
        scanner.restart()
    }

    private func refreshUntilCancelled() async {
        // A cancelled sleep throws: stop there, without one last refresh.
        while (try? await Task.sleep(for: Self.refreshInterval)) != nil {
            refresh(at: .now)
        }
    }

    private func publish() {
        let listed = roster.devices(includingUnnamed: showsUnnamed)
        if listed != devices {
            devices = listed
        }
        let hidden = showsUnnamed ? 0 : roster.unnamedCount
        if hidden != hiddenUnnamedCount {
            hiddenUnnamedCount = hidden
        }
    }
}
