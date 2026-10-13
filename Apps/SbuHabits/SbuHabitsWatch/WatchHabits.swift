import Foundation
import Observation
import WatchConnectivity
import WidgetKit

/// The habits on the Apple Watch: the last grid from the iPhone, kept on the watch, with the taps
/// made here counted at once and queued for the iPhone, which saves them and sends the grid back.
@Observable
final class WatchHabits {
    private(set) var state: WatchState

    @ObservationIgnored private let store: WatchStateStore
    @ObservationIgnored private let calendar: Calendar

    init(store: WatchStateStore = .shared, calendar: Calendar = .current) {
        self.store = store
        self.calendar = calendar
        state = store.load()
    }

    /// The grid on screen: the iPhone's, with the taps it has not confirmed yet.
    var shown: WatchSnapshot? { state.shown }

    func handle(_ event: WatchEvent) {
        switch event {
        case .activated:
            resendPending()
            if let snapshot = state.snapshot, snapshot.isCurrent(at: .now) == false {
                requestRefresh()
            }
        case .snapshot(let snapshot):
            state.receive(snapshot)
            save()
        case .action, .refreshRequest:
            break
        }
    }

    /// One time done, or for an Abitudine da evitare one more time given in.
    func mark(_ habit: Habit, at date: Date = .now) {
        send(habit, .mark, at: date)
    }

    /// Takes today's last mark back.
    func undo(_ habit: Habit, at date: Date = .now) {
        send(habit, .undo, at: date)
    }

    /// Asks the iPhone for today's grid, waking its app; it answers with a new context.
    func requestRefresh() {
        let session = WCSession.default
        guard session.activationState == .activated, session.isReachable else { return }
        session.sendMessage(WatchPayload.refreshRequest, replyHandler: nil)
    }

    private func send(_ habit: Habit, _ kind: WatchAction.Kind, at date: Date) {
        // A grid from a day gone by takes no taps: they would land on the wrong day.
        guard let snapshot = state.snapshot, snapshot.isCurrent(at: date) else { return }
        let action = WatchAction(habitID: habit.id, day: snapshot.today, hour: calendar.component(.hour, from: date), kind: kind)
        state.add(action)
        save()
        transfer(action)
    }

    /// Queues the tap for the iPhone: delivered once, in order, also after the watch was offline.
    private func transfer(_ action: WatchAction) {
        let session = WCSession.default
        guard session.activationState == .activated, let userInfo = try? WatchPayload.userInfo(for: action) else { return }
        session.transferUserInfo(userInfo)
    }

    /// Sends again the taps made before the session was ready; the iPhone applies each one once.
    private func resendPending() {
        let queued = Set(WCSession.default.outstandingUserInfoTransfers.compactMap { WatchPayload.action(from: $0.userInfo)?.id })
        for action in state.pending where queued.contains(action.id) == false {
            transfer(action)
        }
    }

    private func save() {
        // ponytail: a failed write keeps the grid in memory only; the next grid from the iPhone writes again.
        try? store.save(state)
        WidgetCenter.shared.reloadAllTimelines()
    }
}
