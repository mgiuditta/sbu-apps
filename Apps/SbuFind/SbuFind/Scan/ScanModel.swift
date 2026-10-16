import Foundation
import Observation

/// The live scan: the Bluetooth state, the devices heard in the last seconds, the device on the
/// finder and the one Avvisami se lo perdi watches.
///
/// Advertisements arrive many times a second; the list on screen is refreshed twice a second,
/// so rows do not jump at every packet. Nothing is saved but the settings.
@Observable
final class ScanModel {
    /// How often the list on screen catches up with what was heard.
    static let refreshInterval = Duration.milliseconds(500)
    private static let showsUnnamedKey = "showsUnnamed"
    private static let playsSoundKey = "playsSound"
    private static let vibratesKey = "vibrates"
    private static let remembersPlacesKey = "remembersPlaces"
    /// How far back the list shows devices heard before.
    static let recentWindow: TimeInterval = 24 * 60 * 60

    private(set) var state = BluetoothState.starting
    /// The devices on screen, strongest signal first.
    private(set) var devices: [NearbyDevice] = []
    /// Devices heard but left out because they have no name.
    private(set) var hiddenUnnamedCount = 0
    /// The device on the finder, kept after it falls silent so the finder can say for how long.
    private(set) var tracked: TrackedDevice?
    /// The "Ricerca…" card at the bottom of the list.
    private(set) var scanCard = ScanCard()
    /// Goes up by one at each "found it" moment on the finder: the screen celebrates each change.
    private(set) var foundMoments = 0
    /// The device Avvisami se lo perdi watches, if any. Kept only while the app runs: iOS may
    /// give the same device another identifier next time.
    private(set) var watchedID: UUID?
    /// Goes up by one at each lost alert: the screen vibrates on each change.
    private(set) var lostAlerts = 0
    /// The last attempt to watch found notifications not allowed.
    private(set) var notificationsDenied = false

    /// Off by default: most devices without a name are phones and computers around you, not what you lost.
    var showsUnnamed: Bool {
        didSet {
            defaults.set(showsUnnamed, forKey: Self.showsUnnamedKey)
            publish(at: clock())
        }
    }

    /// Ticks on the finder with a short sound, faster as the device gets closer. Off by default:
    /// a sound out of nowhere surprises; it follows the ringer switch.
    var playsSound: Bool {
        didSet { defaults.set(playsSound, forKey: Self.playsSoundKey) }
    }

    /// Ticks on the finder with a tap, faster as the device gets closer. On by default: it lets
    /// you search without looking at the screen.
    var vibrates: Bool {
        didSet { defaults.set(vibrates, forKey: Self.vibratesKey) }
    }

    /// Remember where the iPhone was when each device was last heard. Off until you turn it on,
    /// which asks for location while the app is in use.
    private(set) var remembersPlaces: Bool
    /// The last attempt to remember places found location not allowed.
    private(set) var locationDenied = false
    /// The last sighting of each device, on this iPhone only.
    private(set) var sightings: SightingLog

    @ObservationIgnored private var roster = DeviceRoster()
    @ObservationIgnored private let scanner: any BluetoothScanner
    @ObservationIgnored private let notifier: any LostNotifier
    @ObservationIgnored private let location: any LocationProvider
    @ObservationIgnored private let sightingStore: SightingStore
    @ObservationIgnored private var recorder = SightingRecorder()
    @ObservationIgnored private let activity: any SearchActivityPresenter
    @ObservationIgnored private var activityPlan = SearchActivityPlan()
    @ObservationIgnored private var isRunning = false
    @ObservationIgnored private let defaults: UserDefaults
    @ObservationIgnored private let clock: () -> Date
    @ObservationIgnored private var trackedID: UUID?
    @ObservationIgnored private var warmthTracker = WarmthTracker()
    @ObservationIgnored private var foundMoment = FoundMoment()
    @ObservationIgnored private var lostAlert: LostAlert?
    @ObservationIgnored private var watchedName: String?
    @ObservationIgnored private var watchedLastSeen: Date?

    /// - Parameters:
    ///   - scanner: Core Bluetooth unless a launch argument asks for the fixed scanner.
    ///   - notifier: Local notifications; none with the fixed scanner, where a permission alert
    ///     would cover the screen.
    ///   - location: Core Location; a fixed place with the fixed scanner.
    ///   - sightingStore: Where the sightings are saved.
    ///   - clock: The current time; tests move it by hand.
    init(
        scanner: (any BluetoothScanner)? = nil,
        notifier: (any LostNotifier)? = nil,
        location: (any LocationProvider)? = nil,
        sightingStore: SightingStore = SightingStore(),
        activity: (any SearchActivityPresenter)? = nil,
        defaults: UserDefaults = .standard,
        clock: @escaping () -> Date = { .now }
    ) {
        let fixed = FixedScanner.requested(in: defaults)
        self.scanner = scanner ?? fixed ?? CoreBluetoothScanner()
        self.notifier = notifier ?? (fixed != nil ? AcceptingLostNotifier() : UserNotificationLostNotifier())
        self.location = location ?? (fixed != nil ? FixedLocationProvider() : CoreLocationProvider())
        self.sightingStore = sightingStore
        self.activity = activity ?? (fixed != nil ? NoSearchActivity() : LiveSearchActivity())
        sightings = sightingStore.load()
        remembersPlaces = defaults.bool(forKey: Self.remembersPlacesKey)
        self.defaults = defaults
        self.clock = clock
        showsUnnamed = defaults.bool(forKey: Self.showsUnnamedKey)
        playsSound = defaults.bool(forKey: Self.playsSoundKey)
        // A launch argument arrives as the string "NO": bool(forKey:) reads it, `as? Bool` would not.
        vibrates = defaults.object(forKey: Self.vibratesKey) == nil ? true : defaults.bool(forKey: Self.vibratesKey)
    }

    /// Scans until the calling task is cancelled, as when the app goes to the background.
    func run() async {
        // Each run starts from scratch: the scanner says its state first, which shows the card
        // and starts counting the watched device's silence again.
        state = .starting
        isRunning = true
        if remembersPlaces {
            location.start()
        }
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
        // In the background nothing is heard, so nothing counts as silence.
        lostAlert?.pause()
        // The devices heard until now are left behind: each gets its sighting.
        recordSightings(of: roster.devices(includingUnnamed: false))
        location.stop()
        isRunning = false
    }

    /// Ricorda dove li hai sentiti: on asks for location the first time; off stops following it.
    func setRemembersPlaces(_ isOn: Bool) async {
        if isOn {
            guard await location.requestAccess() else {
                locationDenied = true
                return
            }
            locationDenied = false
            if isRunning {
                location.start()
            }
        } else {
            location.stop()
            recorder.reset()
        }
        remembersPlaces = isOn
        defaults.set(isOn, forKey: Self.remembersPlacesKey)
    }

    /// Cancella le posizioni: every sighting goes, from memory and from the file.
    func forgetPlaces() {
        sightings.removeAll()
        recorder.reset()
        sightingStore.save(sightings)
    }

    /// The last sighting of a device, matched by identifier, else by name and kind.
    func sighting(for device: NearbyDevice) -> Sighting? {
        sightings.latest(id: device.id, name: device.name, kind: device.kind)
    }

    /// Devices heard in the last day and not heard now, newest first, for the list.
    var recentSightings: [Sighting] {
        let listedNames = Set(devices.compactMap(\.name))
        return sightings
            .recent(since: clock().addingTimeInterval(-Self.recentWindow), excluding: Set(devices.map(\.id)))
            .filter { !listedNames.contains($0.name) }
    }

    private func recordSightings(of gone: [NearbyDevice]) {
        guard remembersPlaces else { return }
        let new = recorder.sightings(for: gone, fallback: location.current)
        guard !new.isEmpty else { return }
        for sighting in new {
            sightings.record(sighting)
        }
        sightingStore.save(sightings)
    }

    func handle(_ event: ScanEvent) {
        switch event {
        case .state(let newState):
            let wasReady = state == .ready
            state = newState
            if newState == .ready, !wasReady {
                scanCard.show(at: clock())
                lostAlert?.resume(at: clock())
            }
            if newState != .ready {
                lostAlert?.pause()
                recordSightings(of: roster.devices(includingUnnamed: false))
                roster.removeAll()
                publish(at: clock())
            }
        case .advertisement(let advertisement):
            roster.record(advertisement)
        }
    }

    /// Drops the devices gone silent and shows what was heard since the last refresh.
    func refresh(at now: Date) {
        if remembersPlaces {
            recorder.note(roster.devices(includingUnnamed: false), at: now, place: location.current)
        }
        recordSightings(of: roster.removeStale(at: now))
        publish(at: now)
    }

    /// Cerca di nuovo: forgets every device and listens from scratch.
    func rescan() {
        roster.removeAll()
        scanCard.show(at: clock())
        publish(at: clock())
        scanner.restart()
    }

    /// The card's close button.
    func closeScanCard() {
        scanCard.close()
    }

    /// The finder opened on this device: from now on `tracked` follows it.
    func track(_ id: UUID) {
        trackedID = id
        tracked = nil
        warmthTracker.reset()
        foundMoment.reset()
        activity.apply(activityPlan.close())
        updateTracked(at: clock())
        if let tracked {
            let attributes = SearchActivityAttributes(
                deviceName: tracked.device.name ?? String(localized: "Senza nome"),
                systemImage: tracked.device.kind.systemImage
            )
            activity.apply(activityPlan.begin(attributes, state: .init(tracked: tracked), at: clock()))
        }
    }

    /// The finder closed.
    func stopTracking() {
        trackedID = nil
        tracked = nil
        warmthTracker.reset()
        foundMoment.reset()
        activity.apply(activityPlan.close())
    }

    /// Avvisami se lo perdi on: asks for notifications the first time, then watches the device.
    func watch(_ id: UUID) async {
        guard await notifier.requestPermission() else {
            notificationsDenied = true
            return
        }
        notificationsDenied = false
        watchedID = id
        let device = roster.device(id: id) ?? (tracked?.device.id == id ? tracked?.device : nil)
        watchedName = device?.name
        watchedLastSeen = device?.lastSeen
        var alert = LostAlert(at: clock())
        if state != .ready {
            alert.pause()
        }
        lostAlert = alert
    }

    func stopWatching() {
        watchedID = nil
        watchedName = nil
        watchedLastSeen = nil
        lostAlert = nil
    }

    private func refreshUntilCancelled() async {
        // A cancelled sleep throws: stop there, without one last refresh.
        while (try? await Task.sleep(for: Self.refreshInterval)) != nil {
            refresh(at: clock())
        }
    }

    private func publish(at now: Date) {
        updateTracked(at: now)
        updateWatched(at: now)
        let listed = roster.devices(includingUnnamed: showsUnnamed)
        if listed != devices {
            devices = listed
        }
        let hidden = showsUnnamed ? 0 : roster.unnamedCount
        if hidden != hiddenUnnamedCount {
            hiddenUnnamedCount = hidden
        }
        var card = scanCard
        card.update(at: now, listedDevices: listed.count)
        if card != scanCard {
            scanCard = card
        }
    }

    private func updateTracked(at now: Date) {
        guard let trackedID else { return }
        guard let device = roster.device(id: trackedID) ?? tracked?.device ?? sightedDevice(id: trackedID) else {
            tracked = nil
            return
        }
        // The word moves only on a new reading; while silent it keeps the last one.
        let isNewReading = device.lastSeen != tracked?.device.lastSeen
        let warmth = isNewReading ? warmthTracker.update(with: device.proximity) : tracked?.warmth ?? device.warmth
        let isFound = isNewReading && foundMoment.update(with: device.proximity)
        if isFound {
            foundMoments += 1
        }
        let updated = TrackedDevice(device: device, warmth: warmth, silence: max(0, now.timeIntervalSince(device.lastSeen)))
        if updated != tracked {
            tracked = updated
        }
        activity.apply(activityPlan.follow(.init(tracked: updated), at: now))
        if isFound {
            activity.apply(activityPlan.found(.init(tracked: updated)))
        }
    }

    /// A device opened from "Sentiti prima": not heard now, so at the edge of the scale.
    private func sightedDevice(id: UUID) -> NearbyDevice? {
        guard let sighting = sightings.sightings.first(where: { $0.id == id }) else { return nil }
        return NearbyDevice(id: id, name: sighting.name, kind: sighting.kind, signal: Proximity.farthestRSSI, lastSeen: sighting.date)
    }

    private func updateWatched(at now: Date) {
        guard let watchedID, var alert = lostAlert else { return }
        if let device = roster.device(id: watchedID) {
            watchedLastSeen = device.lastSeen
            watchedName = device.name ?? watchedName
        }
        if alert.update(lastSeen: watchedLastSeen, at: now) {
            notifier.notifyLost(deviceName: watchedName ?? String(localized: "Senza nome"))
            lostAlerts += 1
        }
        lostAlert = alert
    }
}
