import ActivityKit
import SbuKit
import SwiftUI
import WidgetKit

/// Modalità post on the Lock Screen and in the Dynamic Island: the minutes left before the Shield
/// comes back. The full stop is set for the last 4 seconds, when the Shield is back.
struct PostModeLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: PostModeAttributes.self) { context in
            figure(context)
                .activityBackgroundTint(SbuTheme.paper)
                .activitySystemActionForegroundColor(SbuTheme.ink)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.bottom) {
                    figure(context)
                        .environment(\.colorScheme, .dark)
                }
            } compactLeading: {
                Image(systemName: "square.and.pencil")
                    .fontWeight(.medium)
                    .foregroundStyle(SbuTheme.ink)
                    .environment(\.colorScheme, .dark)
                    .accessibilityHidden(true)
            } compactTrailing: {
                timer(context)
            } minimal: {
                timer(context)
            }
        }
    }

    private func figure(_ context: ActivityViewContext<PostModeAttributes>) -> some View {
        SbuLiveFigure(countdown: context.attributes.start...context.attributes.end,
                      label: Text(context.state.isOver ? "Schermo tornato" : "Modalità post"),
                      fullStop: context.state.isOver ? .set : .waiting, accent: .social)
    }

    private func timer(_ context: ActivityViewContext<PostModeAttributes>) -> some View {
        Text(timerInterval: context.attributes.start...context.attributes.end, countsDown: true)
            .font(SbuTheme.caption.monospacedDigit())
            .foregroundStyle(SbuTheme.ink)
            .frame(maxWidth: SbuTheme.gridCell * 2)
            .environment(\.colorScheme, .dark)
    }
}

#Preview("Lock Screen", as: .content, using: PostModeAttributes(start: .now, end: .now.addingTimeInterval(600))) {
    PostModeLiveActivity()
} contentStates: {
    PostModeAttributes.ContentState()
    PostModeAttributes.ContentState(isOver: true)
}
