import SbuKit
import SwiftUI

/// A medicine in a list: its form, name and strength, its schedule, and a word when the stock is low.
struct MedicineRow: View {
    let medicine: MedicineSnapshot

    @Environment(\.calendar) private var calendar
    @Environment(Clock.self) private var clock

    var body: some View {
        HStack(spacing: SbuTheme.space3) {
            Image(systemName: medicine.form.systemImage)
                .fontWeight(.medium)
                .imageScale(.medium)
                .foregroundStyle(SbuTheme.inkMuted)
                .frame(width: SbuTheme.space6)
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: SbuTheme.space1) {
                Text(medicine.strength.isEmpty ? medicine.name : "\(medicine.name) · \(medicine.strength)")
                    .font(SbuTheme.headline)
                    .foregroundStyle(SbuTheme.ink)
                Text(verbatim: ScheduleText.summary(of: medicine.schedule, calendar: calendar))
                    .font(SbuTheme.subheadline)
                    .foregroundStyle(SbuTheme.inkMuted)
                if isEnded {
                    Label("Terminato", systemImage: "flag.checkered")
                        .font(SbuTheme.footnote)
                        .foregroundStyle(SbuTheme.inkMuted)
                } else if medicine.stockLevel.isLow {
                    Label("Scorte basse", systemImage: "exclamationmark.triangle")
                        .font(SbuTheme.footnote)
                        .foregroundStyle(SbuTheme.warning)
                }
            }
        }
        .padding(.vertical, SbuTheme.space1)
        .accessibilityElement(children: .combine)
    }

    private var isEnded: Bool {
        medicine.schedule.end.map { $0 < Day(clock.now, calendar: calendar) } ?? false
    }
}

#Preview("Light") {
    NavigationStack {
        MedicinesView()
    }
    .modelContainer(.preview)
    .environment(Clock())
    .tint(SbuTheme.accentMeds)
}

#Preview("Dark") {
    NavigationStack {
        MedicinesView()
    }
    .modelContainer(.preview)
    .environment(Clock())
    .tint(SbuTheme.accentMeds)
    .preferredColorScheme(.dark)
}
