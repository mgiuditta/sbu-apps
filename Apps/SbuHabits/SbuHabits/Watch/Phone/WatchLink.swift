import Foundation

/// The iPhone's side of the Apple Watch app: it sends today's grid after every change and every
/// new day, and applies the watch's taps through `HabitsModel`, the only source of truth.
final class WatchLink {
    /// How many applied watch actions the iPhone remembers, to confirm them and never apply one twice.
    static let appliedLimit = 200
    private static let appliedKey = "watchAppliedActions"

    private let model: HabitsModel
    private let channel: any WatchChannel
    private let defaults: UserDefaults
    /// The grid sent last, so an unchanged one is not sent again.
    private var lastSent: WatchSnapshot?
    /// While a tap is applied: the grid goes once it is saved and listed as applied.
    private var isApplying = false

    /// - Parameter defaults: Where the applied actions are remembered; tests pass their own.
    init(model: HabitsModel, channel: any WatchChannel, defaults: UserDefaults = .standard) {
        self.model = model
        self.channel = channel
        self.defaults = defaults
    }

    /// The watch actions already applied, newest last.
    var applied: [UUID] {
        (defaults.stringArray(forKey: Self.appliedKey) ?? []).compactMap(UUID.init(uuidString:))
    }

    /// Today's grid as the watch shows it.
    var snapshot: WatchSnapshot {
        WatchSnapshot(habits: model.habits, today: model.today, startHour: model.startHour, firstWeekday: model.firstWeekday, nextDayStart: model.nextDayStart, applied: applied)
    }

    func handle(_ event: WatchEvent) {
        switch event {
        case .activated, .refreshRequest:
            // The watch may have lost what it had: send even an unchanged grid.
            publish(force: true)
        case .action(let action):
            receive(action)
        case .snapshot:
            break
        }
    }

    /// Sends today's grid if it changed since the last one sent, or always with `force`. Never
    /// while the file is unreadable: an empty grid would wipe the watch's.
    func publish(force: Bool = false) {
        guard model.isUnreadable == false, isApplying == false else { return }
        let snapshot = snapshot
        guard force || snapshot != lastSent else { return }
        lastSent = snapshot
        channel.send(snapshot)
    }

    /// Applies a tap from the watch once, on the file as it is now: the widget may have changed it.
    private func receive(_ action: WatchAction) {
        guard applied.contains(action.id) == false else {
            publish(force: true)
            return
        }
        isApplying = true
        model.reload()
        model.apply(action)
        // Remembered even when nothing changes, a habit deleted meanwhile, so the watch drops it.
        defaults.set((applied + [action.id]).suffix(Self.appliedLimit).map(\.uuidString), forKey: Self.appliedKey)
        isApplying = false
        publish()
    }
}
