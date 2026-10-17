import ActivityKit
import SbuKit
import Foundation

/// The search's Live Activity with ActivityKit. Steps run one after the other in the order they
/// come, so a quick end and start never land swapped.
///
/// Each update is marked stale when no newer reading should be expected by then: a few seconds
/// with the app open, two minutes in the background, where iOS reports a saved device far less
/// often and not at all for devices without services. Stale, the Lock Screen says to open Sbu Find
/// instead of showing an old figure.
final class LiveSearchActivity: SearchActivityPresenter {
    /// How long a reading stays current without a newer one, with the app open and in the background.
    nonisolated static let staleInForeground: TimeInterval = 5
    nonisolated static let staleInBackground: TimeInterval = 120
    private var pending: Task<Void, Never>?
    private var staleAfter = LiveSearchActivity.staleInForeground

    func setBackground(_ isBackground: Bool) {
        staleAfter = isBackground ? Self.staleInBackground : Self.staleInForeground
    }

    func apply(_ step: SearchActivityPlan.Step) {
        let staleAfter = staleAfter
        if case .start(let attributes, let state) = step {
            guard ActivityAuthorizationInfo().areActivitiesEnabled else { return }
            // A refused request leaves the search without its activity; the finder still works.
            _ = try? Activity.request(attributes: attributes, content: Self.content(state, staleAfter: staleAfter))
            return
        }
        let previous = pending
        pending = Task {
            await previous?.value
            await Self.carry(out: step, staleAfter: staleAfter)
        }
    }

    func endLeftovers() {
        // Only those there now: an activity started right after is this run's.
        let leftovers = Set(Activity<SearchActivityAttributes>.activities.map(\.id))
        guard !leftovers.isEmpty else { return }
        let previous = pending
        pending = Task {
            await previous?.value
            await Self.end(leftovers)
        }
    }

    private nonisolated static func end(_ ids: Set<String>) async {
        for activity in Activity<SearchActivityAttributes>.activities where ids.contains(activity.id) {
            await activity.end(nil, dismissalPolicy: .immediate)
        }
    }

    private nonisolated static func content(
        _ state: SearchActivityAttributes.ContentState,
        staleAfter: TimeInterval
    ) -> ActivityContent<SearchActivityAttributes.ContentState> {
        ActivityContent(state: state, staleDate: .now.addingTimeInterval(staleAfter))
    }

    private nonisolated static func carry(out step: SearchActivityPlan.Step, staleAfter: TimeInterval) async {
        for activity in Activity<SearchActivityAttributes>.activities {
            switch step {
            case .update(let state):
                await activity.update(content(state, staleAfter: staleAfter))
            case .end(let state?):
                let final = ActivityContent(state: state, staleDate: nil)
                await activity.end(final, dismissalPolicy: .after(.now + SbuTheme.liveEndDelay))
            case .end(nil):
                await activity.end(nil, dismissalPolicy: .immediate)
            case .start, .none:
                break
            }
        }
    }
}
