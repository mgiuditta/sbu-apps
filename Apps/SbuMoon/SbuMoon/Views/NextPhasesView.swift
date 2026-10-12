import SbuKit
import SwiftUI

/// The next full moon and the next new moon, with day and time in the iPhone's time zone.
struct NextPhasesView: View {
    let reading: MoonReading

    var body: some View {
        VStack(spacing: SbuTheme.space3) {
            NextPhaseRow("Prossima luna piena", date: reading.nextFullMoon)
            NextPhaseRow("Prossima luna nuova", date: reading.nextNewMoon)
        }
    }
}

/// One upcoming phase: a label above its date, centred, read as one element.
private struct NextPhaseRow: View {
    private let label: LocalizedStringKey
    private let date: Date

    init(_ label: LocalizedStringKey, date: Date) {
        self.label = label
        self.date = date
    }

    var body: some View {
        VStack(spacing: SbuTheme.space1) {
            Text(label)
                .font(SbuTheme.footnote)
                .foregroundStyle(SbuTheme.inkMuted)

            Text(date, format: .dateTime.weekday(.wide).day().month(.wide).hour().minute())
                .font(SbuTheme.subheadline)
                .monospacedDigit()
                .foregroundStyle(SbuTheme.inkMuted)
        }
        .multilineTextAlignment(.center)
        .fixedSize(horizontal: false, vertical: true)
        .accessibilityElement(children: .combine)
    }
}

#Preview("Light") {
    NextPhasesPreview()
}

#Preview("Dark") {
    NextPhasesPreview()
        .preferredColorScheme(.dark)
}

private struct NextPhasesPreview: View {
    var body: some View {
        NextPhasesView(reading: MoonReading(date: .now, calendar: .current))
            .padding(SbuTheme.space4)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(SbuTheme.surface)
    }
}
