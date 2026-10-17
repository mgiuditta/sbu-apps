import ActivityKit
import SbuKit
import SwiftUI
import WidgetKit

/// The Live Activity of the countdown of an Abitudine a tempo: the Lock Screen and the banner on
/// paper, the Dynamic Island on its own black. The only color is the full stop, set at the end.
struct TimerLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: HabitTimerAttributes.self) { context in
            TimerActivityView(face: Self.face(context), habitID: context.attributes.habitID)
                .activityBackgroundTint(SbuTheme.paper)
                .activitySystemActionForegroundColor(SbuTheme.ink)
        } dynamicIsland: { context in
            let face = Self.face(context)
            return DynamicIsland {
                DynamicIslandExpandedRegion(.bottom) {
                    TimerActivityView(face: face, habitID: context.attributes.habitID)
                        .environment(\.colorScheme, .dark)
                }
            } compactLeading: {
                Self.symbol(face)
            } compactTrailing: {
                TimerActivityCompactTime(face: face)
                    .environment(\.colorScheme, .dark)
            } minimal: {
                Self.symbol(face)
            }
        }
    }

    /// The habit's symbol, a checkmark once done: the time is the trailing side's.
    private static func symbol(_ face: TimerActivityFace) -> some View {
        Image(systemName: face.symbol)
            .font(SbuTheme.caption)
            .fontWeight(.medium)
            .imageScale(.medium)
            .foregroundStyle(SbuTheme.ink)
            .environment(\.colorScheme, .dark)
            .accessibilityHidden(true)
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
