import ActivityKit
import SbuKit
import SwiftUI
import WidgetKit

/// The search's Live Activity: the Lock Screen on paper, the Dynamic Island on its own black.
/// The app's accent reaches only the full stop, set at the "found it" moment.
struct SearchLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: SearchActivityAttributes.self) { context in
            SearchActivityView(attributes: context.attributes, state: context.state, isStale: context.isStale)
                .activityBackgroundTint(SbuTheme.paper)
                .activitySystemActionForegroundColor(SbuTheme.ink)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.bottom) {
                    SearchActivityView(attributes: context.attributes, state: context.state, isStale: context.isStale)
                        .environment(\.colorScheme, .dark)
                }
            } compactLeading: {
                Image(systemName: context.attributes.systemImage)
                    .fontWeight(.medium)
                    .foregroundStyle(SbuTheme.ink)
                    .environment(\.colorScheme, .dark)
                    .accessibilityHidden(true)
            } compactTrailing: {
                Text(Double(context.state.percent) / 100, format: .percent.precision(.fractionLength(0)))
                    .font(SbuTheme.caption.monospacedDigit())
                    .foregroundStyle(SbuTheme.ink)
                    .environment(\.colorScheme, .dark)
            } minimal: {
                Text(Double(context.state.percent) / 100, format: .percent.precision(.fractionLength(0)))
                    .font(SbuTheme.caption.monospacedDigit())
                    .foregroundStyle(SbuTheme.ink)
                    .environment(\.colorScheme, .dark)
            }
        }
    }
}

#Preview("Lock Screen", as: .content, using: SearchActivityAttributes.preview) {
    SearchLiveActivity()
} contentStates: {
    SearchActivityAttributes.ContentState(percent: 64, warmth: .hot)
    SearchActivityAttributes.ContentState(percent: 31, warmth: .cold, isLost: true)
    SearchActivityAttributes.ContentState(percent: 92, warmth: .veryClose, isFound: true)
}

#Preview("Expanded", as: .dynamicIsland(.expanded), using: SearchActivityAttributes.preview) {
    SearchLiveActivity()
} contentStates: {
    SearchActivityAttributes.ContentState(percent: 64, warmth: .hot)
    SearchActivityAttributes.ContentState(percent: 92, warmth: .veryClose, isFound: true)
}

#Preview("Compact", as: .dynamicIsland(.compact), using: SearchActivityAttributes.preview) {
    SearchLiveActivity()
} contentStates: {
    SearchActivityAttributes.ContentState(percent: 64, warmth: .hot)
}
