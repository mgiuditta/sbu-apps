import SbuKit
import SwiftUI

/// What the to-do list says when the filter has nothing to show.
struct TodayEmptyRow: View {
    let filter: TodayFilter

    var body: some View {
        Section {
            Text(title)
                .font(SbuTheme.body)
                .foregroundStyle(SbuTheme.inkMuted)
                .listRowBackground(SbuTheme.surfaceRaised)
        } footer: {
            Text(footer)
        }
    }

    private var title: LocalizedStringKey {
        switch filter {
        case .toDo: "Niente da fare oggi"
        case .upcoming: "Niente in scadenza questa settimana"
        }
    }

    private var footer: LocalizedStringKey {
        switch filter {
        case .toDo: "Le attività tornano qui quando sono da fare. Le trovi tutte in Stanze."
        case .upcoming: "Qui trovi quello che diventa da fare nei prossimi 7 giorni."
        }
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
            TodayEmptyRow(filter: .toDo)
            TodayEmptyRow(filter: .upcoming)
        }
        .scrollContentBackground(.hidden)
        .background(SbuTheme.surface)
    }
}
