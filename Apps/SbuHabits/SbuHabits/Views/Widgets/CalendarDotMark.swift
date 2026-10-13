import SbuKit
import SwiftUI
import WidgetKit

/// One day of the calendar widget.
struct CalendarDotMark: View {
    @Environment(\.widgetRenderingMode) private var renderingMode
    let state: CalendarDotState

    var body: some View {
        switch state {
        case .done:
            Circle()
                .fill(.tint)
                .widgetAccentable()
        case .missed:
            Image(systemName: "xmark")
                .resizable()
                .fontWeight(.semibold)
                .scaledToFit()
                .padding(SbuTheme.hairline * 2)
                .foregroundStyle(SbuTheme.inkMuted)
        case .skipped:
            Image(systemName: "forward")
                .resizable()
                .fontWeight(.medium)
                .scaledToFit()
                .foregroundStyle(SbuTheme.inkMuted)
        case .today:
            Circle()
                .strokeBorder(.tint, lineWidth: SbuTheme.hairline * 2)
                .widgetAccentable()
        case .rest:
            Circle()
                .fill(WidgetTrack.style(for: renderingMode))
        }
    }
}

#Preview("Light") {
    CalendarDotMarkPreview()
}

#Preview("Dark") {
    CalendarDotMarkPreview()
        .preferredColorScheme(.dark)
}

private struct CalendarDotMarkPreview: View {
    var body: some View {
        HStack(spacing: SbuTheme.space2) {
            ForEach([CalendarDotState.done, .missed, .skipped, .today, .rest], id: \.self) { state in
                CalendarDotMark(state: state)
                    .frame(width: SbuTheme.space4, height: SbuTheme.space4)
            }
        }
        .padding(SbuTheme.space4)
        .background(SbuTheme.surface)
        .tint(SbuTheme.accentHabits)
    }
}
