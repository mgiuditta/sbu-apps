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
    /// The other devices on screen, strongest signal first: yours are in `myDevices`.
    private(set) var devices: [NearbyDevice] = []
    /// Your saved devices, in the order you saved them.
    private(set) var myDevices: [SavedDevice]
    /// The device heard now for each of your saved devices, by saved device id.
    private(set) var myMatches: [UUID: DeviceMatch] = [:]
    /// Devices heard but left out because they have no name.
    private(set) var hiddenUnnamedCount = 0
    /// The device on the finder, kept after it falls silent so the finder can say for how long.
    private(set) var tracked: TrackedDevice?
    /// In the first seconds of a scan: the list says it is searching, not that nothing is near.
    private(set) var isSettling = false
    @ObservationIgnored private var scanWindow = ScanWindow()
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
    /// Whether a position can be read with the app in the background (location "Sempre").
    private(set) var placesInBackground = false

    @ObservationIgnored private var roster = DeviceRoster()
    @ObservationIgnored private let scanner: any BluetoothScanner
    @ObservationIgnored private let notifier: any LostNotifier
    @ObservationIgnored private let location: any LocationProvider
    @ObservationIgnored private let sightingStore: SightingStore
    @ObservationIgnored private var recorder = SightingRecorder()
    @ObservationIgnored private let activity: any SearchActivityPresenter
    @ObservationIgnored private let myDevicesStore: MyDevicesStore
    @ObservationIgnored private var activityPlan = SearchActivityPlan()
    @ObservationIgnored private var isRunning = false
    /// The files that could not be read at launch, as with the iPhone locked: nothing is saved
    /// over them until they are read again.
    @ObservationIgnored private var sightingsUnavailable = false
    @ObservationIgnored private var myDevicesUnavailable = false
    @ObservationIgnored private let defaults: UserDefaults
    @ObservationIgnored private let clock: () -> Date
    @ObservationIgnored private var trackedID: UUID?
    @ObservationIgnored private var warmthTracker = WarmthTracker()
    @ObservationIgnored private var foundMoment = FoundMoment()
    @ObservationIgnored private var lostAlert: LostAlert?
    @ObservationIgnored private var watchedName: String?
    @ObservationIgnored private var watchedLastSeen: Date?

    /// The app is in front. In the background only saved devices with services are heard.
    private(set) var isForeground = true
    @ObservationIgnored private var backgroundEnteredAt: Date?
    /// When the background lost alert goes off unless the device is heard again.
    @ObservationIgnored private var lostDeadline: Date?
    @ObservationIgnored private var placeThrottle = PlaceThrottle()
    /// The background position being read, if any: tests wait for it.
    @ObservationIgnored private(set) var pendingPlace: Task<Void, Never>?

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
        myDevicesStore: MyDevicesStore = MyDevicesStore(),
        defaults: UserDefaults = .standard,
        clock: @escaping () -> Date = { .now }
    ) {
        let fixed = FixedScanner.requested(in: defaults)
        self.scanner = scanner ?? fixed ?? CoreBluetoothScanner()
        self.notifier = notifier ?? (fixed != nil ? AcceptingLostNotifier() : UserNotificationLostNotifier())
        self.location = location ?? (fixed != nil ? FixedLocationProvider() : CoreLocationProvider())
        // With the fixed scanner, each launch starts from empty files: UI tests and screenshots
        // never see what an earlier run saved.
        let launch = URL.temporaryDirectory.appending(path: "launch-\(UUID().uuidString)")
        self.sightingStore = fixed != nil ? SightingStore(url: launch.appending(path: "sightings.json")) : sightingStore
        self.activity = activity ?? (fixed != nil ? NoSearchActivity() : LiveSearchActivity())
        let savedSightings = self.sightingStore.read()
        sightings = savedSightings ?? SightingLog()
        sightingsUnavailable = savedSightings == nil
        self.myDevicesStore = fixed != nil ? MyDevicesStore(url: launch.appending(path: "my-devices.json")) : myDevicesStore
        let savedDevices = self.myDevicesStore.read()
        myDevices = savedDevices ?? []
        myDevicesUnavailable = savedDevices == nil
        remembersPlaces = defaults.bool(forKey: Self.remembersPlacesKey)
        placesInBackground = self.location.allowsBackground
        self.defaults = defaults
        self.clock = clock
        showsUnnamed = defaults.bool(forKey: Self.showsUnnamedKey)
        playsSound = defaults.bool(forKey: Self.playsSoundKey)
        // A launch argument arrives as the string "NO": bool(forKey:) reads it, `as? Bool` would not.
        vibrates = defaults.object(forKey: Self.vibratesKey) == nil ? true : defaults.bool(forKey: Self.vibratesKey)
    }

    /// Scans for the life of the app: from launch, also a launch in the background by iOS for a
    /// saved device, until the scanner finishes or the calling task is cancelled.
    func run() async {
        // The scanner says its state first, which starts the scan's first seconds.
        state = .starting
        isRunning = true
        if remembersPlaces, isForeground {
            location.start()
        }
        scanner.listen(currentScanMode)
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
            if isRunning, isForeground {
                location.start()
            }
        } else {
            location.stop()
            recorder.reset()
        }
        remembersPlaces = isOn
        defaults.set(isOn, forKey: Self.remembersPlacesKey)
    }

    /// Anche con l'app chiusa: asks for location "Sempre", only when you choose it.
    func allowPlacesInBackground() async {
        let granted = await location.requestBackgroundAccess()
        locationDenied = !granted
        placesInBackground = granted
    }

    /// The app came to the front or went to the background.
    ///
    /// In the background the scan listens only for your saved devices with services, if Avvisami
    /// se lo perdi or Ricorda dove li hai sentiti needs them; the lost alert becomes a notification
    /// set for the deadline, moved on each time the device is heard. Back in front, the deadline is
    /// cancelled and the foreground alert goes on, without repeating one already shown.
    func setForeground(_ foreground: Bool) {
        guard foreground != isForeground else { return }
        let now = clock()
        isForeground = foreground
        activity.setBackground(!foreground)
        if foreground {
            backgroundEnteredAt = nil
            notifier.cancelScheduledLost()
            let deadlinePassed = lostDeadline.map { $0 <= now } ?? false
            lostDeadline = nil
            lostAlert?.resume(at: now)
            if deadlinePassed {
                lostAlert?.markAlerted(lastSeen: watchedLastSeen)
            }
            if remembersPlaces, isRunning {
                location.start()
            }
        } else {
            backgroundEnteredAt = now
            location.stop()
            // Devices iOS will not report in the background are left behind: each gets its sighting.
            let followed = Set(BackgroundPlan.placedInBackground(saved: myDevices, placesInBackground: readsPlacesInBackground).map(\.deviceID))
            recordSightings(of: roster.devices(includingUnnamed: false).filter { !followed.contains($0.id) })
            lostAlert?.pause()
            scheduleLostDeadline(at: now)
        }
        scanner.listen(currentScanMode)
    }

    /// Whether Avvisami se lo perdi keeps watching this device with the app in the background.
    func canWatchInBackground(_ deviceID: UUID) -> Bool {
        BackgroundPlan.canWatchInBackground(deviceID: deviceID, saved: myDevices)
    }

    private var currentScanMode: ScanMode {
        BackgroundPlan.scanMode(isForeground: isForeground, saved: myDevices, watchedDeviceID: watchedID, placesInBackground: readsPlacesInBackground)
    }

    /// Ricorda dove li hai sentiti is on and location allows reading a place in the background.
    private var readsPlacesInBackground: Bool {
        remembersPlaces && location.allowsBackground
    }

    /// Sets, or moves on, the background alert for the watched device, when it can be followed.
    private func scheduleLostDeadline(at now: Date) {
        guard !isForeground, let watchedID, lostAlert != nil, canWatchInBackground(watchedID), let entered = backgroundEnteredAt else { return }
        let deadline = BackgroundPlan.lostDeadline(lastSeen: watchedLastSeen, enteredBackground: entered, silence: SignalTuning.current.lostAlertBackground)
        lostDeadline = deadline
        notifier.scheduleLost(deviceName: watchedName ?? String(localized: "Senza nome"), at: deadline)
    }

    /// A device heard with the app in the background: it moves the lost deadline on, and, if it
    /// is one of yours under its saved identifier, its place is read and saved.
    private func heardInBackground(_ advertisement: Advertisement) {
        if advertisement.id == watchedID {
            watchedLastSeen = max(watchedLastSeen ?? advertisement.date, advertisement.date)
            scheduleLostDeadline(at: advertisement.date)
        }
        // No refresh timer runs while iOS keeps the app suspended: the finder and its Live
        // Activity catch up at each report.
        refresh(at: advertisement.date)
        guard readsPlacesInBackground,
              let saved = savedDevice(forDeviceID: advertisement.id),
              placeThrottle.shouldAsk(for: advertisement.id, at: advertisement.date) else { return }
        let date = advertisement.date
        pendingPlace = Task {
            guard let place = await location.oneShot() else { return }
            recordBackgroundSighting(of: saved, heardAt: date, place: place)
        }
    }

    private func recordBackgroundSighting(of saved: SavedDevice, heardAt date: Date, place: Coordinate) {
        sightings.record(Sighting(id: saved.deviceID, name: saved.advertisedName ?? saved.name, kind: saved.kind, date: date, place: place))
        saveSightings()
    }

    /// Cancella le posizioni: every sighting goes, from memory and from the file.
    func forgetPlaces() {
        sightings.removeAll()
        recorder.reset()
        // Asked for: the file goes even if it could not be read.
        sightingsUnavailable = false
        saveSightings()
    }

    /// Reads again the files that could not be read at launch, now that the iPhone is unlocked:
    /// what was heard meanwhile joins what they keep.
    func reloadUnavailableFiles() {
        if sightingsUnavailable, let saved = sightingStore.read() {
            var merged = saved
            for sighting in sightings.sightings {
                merged.record(sighting)
            }
            sightings = merged
            sightingsUnavailable = false
            saveSightings()
        }
        if myDevicesUnavailable, let saved = myDevicesStore.read() {
            let added = myDevices.filter { mine in !saved.contains { $0.id == mine.id } }
            myDevices = saved + added
            myDevicesUnavailable = false
            if !added.isEmpty {
                saveMyDevices()
            }
            publish(at: clock())
            scanner.listen(currentScanMode)
        }
    }

    private func saveSightings() {
        guard !sightingsUnavailable else { return }
        sightingStore.save(sightings)
    }

    private func saveMyDevices() {
        guard !myDevicesUnavailable else { return }
        myDevicesStore.save(myDevices)
    }

    /// The last sighting of the device heard under this identifier.
    func sighting(for device: NearbyDevice) -> Sighting? {
        sightings.latest(id: device.id)
    }

    /// Devices heard in the last day and not heard now, newest first, for the list.
    var recentSightings: [Sighting] {
        var shownNames = Set(devices.compactMap(\.name))
        // A device that changes identifier leaves one sighting per identifier: the newest shows.
        return sightings
            .recent(since: clock().addingTimeInterval(-Self.recentWindow), excluding: Set(devices.map(\.id)))
            .filter { shownNames.insert($0.name).inserted }
    }

    private func recordSightings(of gone: [NearbyDevice]) {
        guard remembersPlaces else { return }
        // A device that only says the name of one of yours places nothing: it could be anyone's.
        let trusted = gone.filter { probableSavedDevice(forDeviceID: $0.id) == nil }
        let new = recorder.sightings(for: trusted, fallback: location.current)
        guard !new.isEmpty else { return }
        for sighting in new {
            sightings.record(sighting)
        }
        saveSightings()
    }

    func handle(_ event: ScanEvent) {
        switch event {
        case .state(let newState):
            let wasReady = state == .ready
            state = newState
            if newState == .ready, !wasReady {
                scanWindow.start(at: clock())
                isSettling = true
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
            if !isForeground {
                heardInBackground(advertisement)
            }
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
        scanWindow.start(at: clock())
        isSettling = true
        publish(at: clock())
        scanner.restart()
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
                deviceName: savedDevice(forDeviceID: id)?.name ?? tracked.device.name ?? String(localized: "Senza nome"),
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
        watchedName = savedDevice(forDeviceID: id)?.name ?? device?.name
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
        lostDeadline = nil
        notifier.cancelScheduledLost()
    }

    private func refreshUntilCancelled() async {
        // A cancelled sleep throws: stop there, without one last refresh.
        while (try? await Task.sleep(for: Self.refreshInterval)) != nil {
            refresh(at: clock())
        }
    }

    /// I miei dispositivi: pins a heard device to the top with your name for it.
    func saveDevice(_ device: NearbyDevice, name: String) {
        guard savedDevice(forDeviceID: device.id) == nil else { return }
        myDevices.append(SavedDevice(name: SavedDevice.displayName(name, fallback: device.name), device: device))
        saveMyDevices()
        publish(at: clock())
    }

    func renameDevice(_ id: UUID, to name: String) {
        guard let index = myDevices.firstIndex(where: { $0.id == id }) else { return }
        myDevices[index].name = SavedDevice.displayName(name, fallback: myDevices[index].advertisedName)
        saveMyDevices()
    }

    func forgetDevice(_ id: UUID) {
        myDevices.removeAll { $0.id == id }
        saveMyDevices()
        publish(at: clock())
    }

    /// The saved device an identifier belongs to: only the identifier it was saved with.
    func savedDevice(forDeviceID deviceID: UUID) -> SavedDevice? {
        myDevices.first { $0.deviceID == deviceID }
    }

    /// The saved device a heard device only says it is, by name: probably yours, never for sure.
    func probableSavedDevice(forDeviceID deviceID: UUID) -> SavedDevice? {
        myDevices.first { saved in
            guard let match = myMatches[saved.id] else { return false }
            return !match.isByIdentifier && match.device.id == deviceID
        }
    }

    private func publish(at now: Date) {
        updateMine()
        updateTracked(at: now)
        updateWatched(at: now)
        let mineIDs = Set(myMatches.values.map(\.device.id))
        let listed = roster.devices(includingUnnamed: showsUnnamed).filter { !mineIDs.contains($0.id) }
        if listed != devices {
            devices = listed
        }
        let hidden = showsUnnamed ? 0 : roster.unnamedCount
        if hidden != hiddenUnnamedCount {
            hiddenUnnamedCount = hidden
        }
        let settling = scanWindow.isSettling(at: now)
        if settling != isSettling {
            isSettling = settling
        }
    }

    /// Finds your devices among the ones heard. A match by name is shown as probable and changes
    /// nothing saved: any nearby device can advertise your earbuds' name.
    private func updateMine() {
        guard !myDevices.isEmpty else {
            if !myMatches.isEmpty { myMatches = [:] }
            return
        }
        let matches = DeviceMatcher.match(myDevices, among: roster.devices(includingUnnamed: true))
        if matches != myMatches {
            myMatches = matches
        }
    }

    private func updateTracked(at now: Date) {
        guard let trackedID else { return }
        guard let device = roster.device(id: trackedID) ?? tracked?.device ?? sightedDevice(id: trackedID) ?? rememberedDevice(id: trackedID) else {
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

    /// One of your devices opened while not heard: at the edge of the scale, heard long ago.
    private func rememberedDevice(id: UUID) -> NearbyDevice? {
        guard let saved = myDevices.first(where: { $0.deviceID == id }) else { return nil }
        return NearbyDevice(id: id, name: saved.advertisedName, kind: saved.kind, signal: Proximity.farthestRSSI, lastSeen: .distantPast, companyID: saved.companyID)
    }

    private func updateWatched(at now: Date) {
        guard let watchedID, var alert = lostAlert else { return }
        if let device = roster.device(id: watchedID) {
            watchedLastSeen = device.lastSeen
            watchedName = savedDevice(forDeviceID: watchedID)?.name ?? device.name ?? watchedName
        }
        if alert.update(lastSeen: watchedLastSeen, at: now) {
            notifier.notifyLost(deviceName: watchedName ?? String(localized: "Senza nome"))
            lostAlerts += 1
        }
        lostAlert = alert
    }
}
