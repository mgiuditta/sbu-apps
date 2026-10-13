import SbuKit
import SwiftUI

/// A Nota del giorno in a habit's page: the day, then the first lines of the text.
struct NoteRow: View {
    @Environment(\.calendar) private var calendar

    let day: LogicalDay
    let text: String

    var body: some View {
        VStack(alignment: .leading, spacing: SbuTheme.space1) {
            Text(day.noon(in: calendar), format: .dateTime.weekday(.wide).day().month(.wide).year())
                .font(SbuTheme.subheadline)
                .foregroundStyle(SbuTheme.inkMuted)
            Text(text)
                .font(SbuTheme.body)
                .foregroundStyle(SbuTheme.ink)
                .lineLimit(3)
                .multilineTextAlignment(.leading)
        }
        .padding(.vertical, SbuTheme.space1)
        .accessibilityElement(children: .combine)
    }
}

#Preview("Light") {
    List {
        NoteRow(day: LogicalDay(.now), text: "Venti pagine prima di dormire.")
    }
    .listStyle(.insetGrouped)
}

#Preview("Dark") {
    List {
        NoteRow(day: LogicalDay(.now), text: "Venti pagine prima di dormire.")
    }
    .listStyle(.insetGrouped)
    .preferredColorScheme(.dark)
}
