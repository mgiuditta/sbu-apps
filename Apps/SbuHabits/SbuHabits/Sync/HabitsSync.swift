import Foundation
import Observation

/// Sincronizza con iCloud: off until the user turns it on in Impostazioni. While on, the same
/// habits file goes to a hidden copy in the user's own iCloud, never to sbu.dev, and every
/// iPhone merges that copy into its own with `HabitsMerge`: at launch, when the app comes back,
/// shortly after each change, and whenever iCloud brings a change from another iPhone.
///
/// The file in the App Group stays the truth on this iPhone, for the app and the widget; with
/// sync off nothing else is read or written.
@Observable
final class HabitsSync {
    /// The user turned it on, on this iPhone. Never synced itself.
    private(set) var isEnabled: Bool
    /// iCloud is on with iCloud Drive: without it the switch is off and says why.
    private(set) var isAvailable = false
    /// The copy on iCloud comes from a newer Sbu Habits: it is never read or overwritten.
    private(set) var isNewerOnICloud = false

    @ObservationIgnored private let model: HabitsModel
    @ObservationIgnored private let remote: (any HabitsRemote)?
    @ObservationIgnored private let base: HabitsStore
    @ObservationIgnored private let preferences: UserDefaults?
    @ObservationIgnored private let account: @MainActor () -> NSObject?
    @ObservationIgnored private let now: () -> Date
    @ObservationIgnored private let watcher: ICloudWatcher?
    @ObservationIgnored private var isSyncing = false
    @ObservationIgnored private var needsAnotherPass = false
    @ObservationIgnored private var pending: Task<Void, Never>?

    private static let enabledKey = "syncsWithICloud"
    private static let accountKey = "syncAccount"

    /// - Parameters:
    ///   - remote: The copy on iCloud; `nil` never syncs, for UI tests and screenshots.
    ///   - base: Where the file as of the last sync is kept, on this iPhone only.
    ///   - preferences: Where the switch is kept; `nil` keeps it in memory, off at each launch.
    ///   - account: The iCloud account signed in, as iCloud's opaque token, or `nil` without one.
    ///   - watcher: Tells when iCloud changes the copy; `nil` in tests.
    init(model: HabitsModel, remote: (any HabitsRemote)?, base: HabitsStore, preferences: UserDefaults?, account: @escaping @MainActor () -> NSObject?, watcher: ICloudWatcher? = nil, now: @escaping () -> Date = Date.init) {
        self.model = model
        self.remote = remote
        self.base = base
        self.preferences = preferences
        self.account = account
        self.watcher = watcher
        self.now = now
        isEnabled = preferences?.bool(forKey: Self.enabledKey) ?? false
        model.didSave = { [weak self] in
            self?.scheduleSync(after: .seconds(2))
        }
        watcher?.onChange = { [weak self] in
            self?.scheduleSync(after: .milliseconds(500))
        }
        checkAccount()
    }

    /// At launch: follows iCloud while the switch is on. The first sync waits for the watcher's
    /// first look, which knows whether a copy exists on iCloud.
    func start() {
        guard isEnabled, isAvailable else { return }
        if let watcher {
            watcher.start()
        } else {
            scheduleSync(after: .zero)
        }
    }

    /// Turns sync on or off. Turning it on merges both sides at once, without asking; turning it
    /// off leaves the habits on this iPhone as they are and the copy on iCloud where it is.
    func setEnabled(_ on: Bool) async {
        guard on != isEnabled, on == false || isAvailable else { return }
        if on {
            isEnabled = true
            preferences?.set(true, forKey: Self.enabledKey)
            preferences?.set(account().flatMap(Self.archive), forKey: Self.accountKey)
            watcher?.start()
            await sync()
        } else {
            turnOff()
        }
    }

    /// When the app comes back: the account may have changed, and another iPhone may have synced.
    func appDidBecomeActive() async {
        checkAccount()
        await sync()
    }

    /// When the app leaves: sends a change still waiting for its delay.
    func appDidEnterBackground() {
        guard pending != nil else { return }
        scheduleSync(after: .zero)
    }

    /// Reads the copy on iCloud, merges it with this iPhone's habits, saves the result here and
    /// writes it back. One pass at a time; a request during a pass runs one more after it.
    func sync() async {
        // Before the watcher's first look, a copy still only in the cloud could seem missing.
        guard isEnabled, isAvailable, let remote, watcher?.hasGathered ?? true else { return }
        guard isSyncing == false else {
            needsAnotherPass = true
            return
        }
        isSyncing = true
        repeat {
            needsAnotherPass = false
            await pass(with: remote)
        } while needsAnotherPass && isEnabled
        isSyncing = false
    }

    private func pass(with remote: any HabitsRemote) async {
        guard let read = try? await remote.read() else { return }
        // The switch, the account or the file may have changed during the read.
        guard isEnabled, isAvailable, model.isUnreadable == false else { return }
        var current: HabitsFile?
        var conflicts: [RemoteConflict] = []
        switch read {
        case .downloading:
            // The watcher calls again once it is here.
            return
        case .missing:
            isNewerOnICloud = false
        case .found(let data, let found):
            do {
                current = try HabitsImport(data: data).file
            } catch .newerVersion {
                isNewerOnICloud = true
                return
            } catch {
                // A damaged copy is replaced by this iPhone's habits.
                current = nil
            }
            isNewerOnICloud = false
            conflicts = found
        }
        var remoteFile = current ?? HabitsFile()
        var merged: [RemoteConflict] = []
        for conflict in conflicts {
            // A version from a newer app stays unresolved, so it is never lost.
            guard let file = try? HabitsImport(data: conflict.data).file else { continue }
            remoteFile = HabitsMerge.merge(remoteFile, file, base: nil, now: now())
            merged.append(conflict)
        }

        let result = HabitsMerge.merge(model.file, remoteFile, base: lastSynced(), now: now())
        if result != model.file {
            model.applySynced(result)
        }
        if result != current || merged.isEmpty == false {
            guard let data = try? JSONEncoder().encode(result) else { return }
            do {
                try await remote.write(data, resolving: merged)
            } catch {
                return
            }
        }
        // Turned off during the write: the next time on starts from no last sync.
        guard isEnabled else { return }
        try? base.save(result)
    }

    /// The file as of the last sync on this iPhone, `nil` before the first one.
    private func lastSynced() -> HabitsFile? {
        guard FileManager.default.fileExists(atPath: base.url.path(percentEncoded: false)) else { return nil }
        return try? base.load()
    }

    private func scheduleSync(after delay: Duration) {
        guard isEnabled else { return }
        pending?.cancel()
        pending = Task { [weak self] in
            if delay > .zero {
                try? await Task.sleep(for: delay)
            }
            guard Task.isCancelled == false, let self else { return }
            pending = nil
            await sync()
        }
    }

    /// Without iCloud the switch goes off; on another iCloud account too, so one person's
    /// habits never merge into someone else's iCloud.
    private func checkAccount() {
        let current = account()
        isAvailable = current != nil
        // Compared token to token, as iCloud advises; one that cannot be read back is no reason to stop.
        let saved = preferences?.data(forKey: Self.accountKey).flatMap(Self.unarchive)
        let isAnotherAccount = current != nil && saved != nil && current?.isEqual(saved) == false
        if isEnabled, current == nil || isAnotherAccount {
            turnOff()
        }
    }

    private static func archive(_ account: NSObject) -> Data? {
        try? NSKeyedArchiver.archivedData(withRootObject: account, requiringSecureCoding: false)
    }

    /// Reads back a token this app saved in its own defaults.
    private static func unarchive(_ data: Data) -> NSObject? {
        guard let unarchiver = try? NSKeyedUnarchiver(forReadingFrom: data) else { return nil }
        // iCloud's token does not promise secure coding; the data only ever comes from this app.
        unarchiver.requiresSecureCoding = false
        defer { unarchiver.finishDecoding() }
        return unarchiver.decodeObject(forKey: NSKeyedArchiveRootObjectKey) as? NSObject
    }

    /// Stops following iCloud; the habits on this iPhone stay as they are.
    private func turnOff() {
        isEnabled = false
        preferences?.set(false, forKey: Self.enabledKey)
        pending?.cancel()
        pending = nil
        watcher?.stop()
        isNewerOnICloud = false
        // The next time it is turned on, both sides merge as on the first day.
        try? FileManager.default.removeItem(at: base.url)
    }
}
