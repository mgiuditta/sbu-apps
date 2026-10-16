import SbuKit
import SwiftUI

/// What today says with no dose to show: add the first medicine, or nothing due that day.
struct TodayEmptyRow: View {
    let hasMedicines: Bool
    let isToday: Bool
    let addMedicine: () -> Void

    var body: some View {
        Section {
            VStack(alignment: .leading, spacing: SbuTheme.space3) {
                Text(title)
                    .font(SbuTheme.headline)
                    .foregroundStyle(SbuTheme.ink)
                Text(message)
                    .font(SbuTheme.subheadline)
                    .foregroundStyle(SbuTheme.inkMuted)
                if !hasMedicines {
                    SbuButton("Aggiungi farmaco", action: addMedicine)
                        .accessibilityIdentifier("addFirstMedicine")
                }
            }
            .padding(.vertical, SbuTheme.space2)
            .listRowBackground(SbuTheme.surfaceRaised)
        }
    }

    private var title: LocalizedStringKey {
        hasMedicines ? (isToday ? "Niente da prendere oggi" : "Niente da prendere") : "Nessun farmaco"
    }

    private var message: LocalizedStringKey {
        hasMedicines
            ? "Nessuna dose prevista in questo giorno."
            : "Aggiungi un farmaco con i suoi orari: qui trovi le dosi del giorno, e una notifica te le ricorda."
    }
}

#Preview("Light") {
    TodayEmptyRowPreview()
}

#Preview("Dark") {
    TodayEmptyRowPreview()
        .preferredColorScheme(.dark)
}

private struct TodayEmptyRowPreview: View {
    var body: some View {
        List {
            TodayEmptyRow(hasMedicines: false, isToday: true) {}
            TodayEmptyRow(hasMedicines: true, isToday: false) {}
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
        .background(SbuTheme.surface)
        .tint(SbuTheme.accentMeds)
    }
}
