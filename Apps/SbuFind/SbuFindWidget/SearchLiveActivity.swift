import ActivityKit
import SbuKit
import SwiftUI
import WidgetKit

/// The search's Live Activity: the Lock Screen on paper, the Dynamic Island on its own black,
/// in the app's one accent.
struct SearchLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: SearchActivityAttributes.self) { context in
            SearchActivityView(attributes: context.attributes, state: context.state, isStale: context.isStale)
                .padding(SbuTheme.space4)
                .tint(SbuTheme.accentFind)
                .activityBackgroundTint(SbuTheme.surface)
                .activitySystemActionForegroundColor(SbuTheme.ink)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.bottom) {
                    SearchActivityView(attributes: context.attributes, state: context.state, isStale: context.isStale)
                        .tint(SbuTheme.accentFind)
                        .environment(\.colorScheme, .dark)
                }
            } compactLeading: {
                SignalRing(proximity: context.state.proximity, systemImage: context.attributes.systemImage, lineWidth: SbuTheme.space1)
                    .tint(SbuTheme.accentFind)
                    .environment(\.colorScheme, .dark)
            } compactTrailing: {
                Text(Double(context.state.percent) / 100, format: .percent.precision(.fractionLength(0)))
                    .font(SbuTheme.caption.monospacedDigit())
                    .foregroundStyle(SbuTheme.ink)
                    .environment(\.colorScheme, .dark)
            } minimal: {
                SignalRing(proximity: context.state.proximity, systemImage: context.attributes.systemImage, lineWidth: SbuTheme.space1)
                    .tint(SbuTheme.accentFind)
                    .environment(\.colorScheme, .dark)
            }
            .keylineTint(SbuTheme.accentFind)
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
}

#Preview("Compact", as: .dynamicIsland(.compact), using: SearchActivityAttributes.preview) {
    SearchLiveActivity()
} contentStates: {
    SearchActivityAttributes.ContentState(percent: 64, warmth: .hot)
}
