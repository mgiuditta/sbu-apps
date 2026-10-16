import ActivityKit
import Foundation

/// The search's Live Activity with ActivityKit. Steps run one after the other in the order they
/// come, so a quick end and start never land swapped.
///
/// iOS stops the scan when Sbu Find is not in front, so each update is marked stale a few
/// seconds later: the Lock Screen then says to open Sbu Find instead of showing an old figure.
final class LiveSearchActivity: SearchActivityPresenter {
    /// How long a reading stays current on the Lock Screen without a newer one.
    nonisolated static let staleAfter: TimeInterval = 5
    /// How long the "Trovato" state stays before the activity goes.
    nonisolated static let foundLinger: TimeInterval = 4

    private var pending: Task<Void, Never>?

    func apply(_ step: SearchActivityPlan.Step) {
        if case .start(let attributes, let state) = step {
            guard ActivityAuthorizationInfo().areActivitiesEnabled else { return }
            // A refused request leaves the search without its activity; the finder still works.
            _ = try? Activity.request(attributes: attributes, content: Self.content(state))
            return
        }
        let previous = pending
        pending = Task {
            await previous?.value
            await Self.carry(out: step)
        }
    }

    private nonisolated static func content(_ state: SearchActivityAttributes.ContentState) -> ActivityContent<SearchActivityAttributes.ContentState> {
        ActivityContent(state: state, staleDate: .now.addingTimeInterval(staleAfter))
    }

    private nonisolated static func carry(out step: SearchActivityPlan.Step) async {
        for activity in Activity<SearchActivityAttributes>.activities {
            switch step {
            case .update(let state):
                await activity.update(content(state))
            case .end(let state?):
                let final = ActivityContent(state: state, staleDate: nil)
                await activity.end(final, dismissalPolicy: .after(.now.addingTimeInterval(foundLinger)))
            case .end(nil):
                await activity.end(nil, dismissalPolicy: .immediate)
            case .start, .none:
                break
            }
        }
    }
}
