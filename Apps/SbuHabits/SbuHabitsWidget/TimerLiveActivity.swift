import ActivityKit
import SbuKit
import SwiftUI
import WidgetKit

/// The Live Activity of the countdown of an Abitudine a tempo: the Lock Screen and the banner on
/// paper, the Dynamic Island on its own black, in the app's one accent.
struct TimerLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: HabitTimerAttributes.self) { context in
            TimerActivityView(face: Self.face(context), habitID: context.attributes.habitID)
                .padding(SbuTheme.space4)
                .activityBackgroundTint(SbuTheme.surface)
                .activitySystemActionForegroundColor(SbuTheme.ink)
        } dynamicIsland: { context in
            let face = Self.face(context)
            return DynamicIsland {
                DynamicIslandExpandedRegion(.bottom) {
                    TimerActivityView(face: face, habitID: context.attributes.habitID)
                        .environment(\.colorScheme, .dark)
                }
            } compactLeading: {
                TimerActivityRing(face: face, symbolFont: SbuTheme.caption)
                    .environment(\.colorScheme, .dark)
            } compactTrailing: {
                TimerActivityCompactTime(face: face)
                    .environment(\.colorScheme, .dark)
            } minimal: {
                TimerActivityRing(face: face, symbolFont: SbuTheme.caption)
                    .environment(\.colorScheme, .dark)
            }
            .keylineTint(SbuTheme.accentHabits)
        }
    }

    private static func face(_ context: ActivityViewContext<HabitTimerAttributes>) -> TimerActivityFace {
        TimerActivityFace(attributes: context.attributes, state: context.state, isStale: context.isStale)
    }
}

#Preview("Lock Screen", as: .content, using: HabitTimerAttributes.preview) {
    TimerLiveActivity()
} contentStates: {
    HabitTimerAttributes.ContentState.previewRunning
    HabitTimerAttributes.ContentState.previewPaused
    HabitTimerAttributes.ContentState.done
}

#Preview("Expanded", as: .dynamicIsland(.expanded), using: HabitTimerAttributes.preview) {
    TimerLiveActivity()
} contentStates: {
    HabitTimerAttributes.ContentState.previewRunning
    HabitTimerAttributes.ContentState.previewPaused
}

#Preview("Compact", as: .dynamicIsland(.compact), using: HabitTimerAttributes.preview) {
    TimerLiveActivity()
} contentStates: {
    HabitTimerAttributes.ContentState.previewRunning
    HabitTimerAttributes.ContentState.previewPaused
}

#Preview("Minimal", as: .dynamicIsland(.minimal), using: HabitTimerAttributes.preview) {
    TimerLiveActivity()
} contentStates: {
    HabitTimerAttributes.ContentState.previewRunning
}
