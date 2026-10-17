import SbuKit
import SwiftData
import SwiftUI

/// Previews of the chore screen's sections on a sample chore with a history.
struct ChoreSectionsPreview: View {
    var body: some View {
        ChoreSectionsPreviewList()
            .modelContainer(.preview)
            .environment(Clock())
            .environment(\.sbuAccent, .tidy)
    }
}

private struct ChoreSectionsPreviewList: View {
    @Query private var chores: [Chore]

    var body: some View {
        List {
            if let chore = chores.first(where: { !($0.completions ?? []).isEmpty }) {
                ChoreStatusSection(chore: chore, state: chore.state(at: .now, calendar: .current))
                ChoreHistorySection(chore: chore)
            }
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
        .background(SbuTheme.paper)
    }
}
