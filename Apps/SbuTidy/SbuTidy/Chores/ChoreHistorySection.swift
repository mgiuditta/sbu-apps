import SbuKit
import SwiftData
import SwiftUI

/// Tody's "Storico": every time the chore was done, latest first; a wrong one can be removed.
struct ChoreHistorySection: View {
    let chore: Chore

    @Environment(\.modelContext) private var modelContext
    @Environment(Clock.self) private var clock
    @State private var removing: Completion?

    var body: some View {
        Section {
            ForEach(chore.history) { completion in
                Text(completion.date, format: .dateTime.weekday(.wide).day().month(.wide).year())
                    .font(SbuTheme.body)
                    .foregroundStyle(SbuTheme.ink)
                    .swipeActions {
                        Button("Elimina", systemImage: "trash", role: .destructive) { removing = completion }
                    }
                    .accessibilityIdentifier("historyEntry")
            }
            .listRowBackground(SbuTheme.surfaceRaised)
        } header: {
            Text("Storico")
        } footer: {
            if chore.history.isEmpty {
                Text("Non l'hai ancora segnata come fatta.")
            }
        }
        .confirmationDialog("Eliminare questa volta dallo storico?", isPresented: isRemoving, titleVisibility: .visible, presenting: removing) { completion in
            Button("Elimina", role: .destructive) { remove(completion) }
        } message: { _ in
            Text("Se è la più recente, lo sporco riparte dalla volta prima.")
        }
    }

    private var isRemoving: Binding<Bool> {
        Binding { removing != nil } set: { if !$0 { removing = nil } }
    }

    private func remove(_ completion: Completion) {
        chore.remove(completion, in: modelContext)
        try? modelContext.save()
        clock.refresh()
    }
}

#Preview("Light") {
    ChoreSectionsPreview()
}

#Preview("Dark") {
    ChoreSectionsPreview()
        .preferredColorScheme(.dark)
}
