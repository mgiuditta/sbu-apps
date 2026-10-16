import SbuKit
import SwiftData
import SwiftUI

/// Tody's room screen: what is to do in it, then all its chores, the dirtiest first.
struct RoomView: View {
    let room: Room

    @Environment(\.modelContext) private var modelContext
    @Environment(\.calendar) private var calendar
    @Environment(\.dismiss) private var dismiss
    @Environment(Clock.self) private var clock
    @State private var isAddingChore = false
    @State private var isEditing = false
    @State private var isConfirmingDelete = false
    @State private var doneCount = 0

    var body: some View {
        // A room deleted from its own menu is gone before the screen is.
        if room.isDeleted || room.modelContext == nil {
            Color.clear
        } else {
            content
        }
    }

    private var content: some View {
        let ranked = Urgency.sorted(room.choreList.map(\.snapshot), at: clock.now, calendar: calendar)
        let byID = Dictionary(room.choreList.map { ($0.id, $0) }, uniquingKeysWith: { first, _ in first })
        let summary = RoomSummary(ranked.map(\.state))
        return List {
            Section {
                RoomFigure(summary: summary)
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
            }
            Section {
                ForEach(ranked, id: \.chore.id) { entry in
                    if let chore = byID[entry.chore.id] {
                        NavigationLink(value: chore) {
                            ChoreRow(name: entry.chore.name, effort: entry.chore.effort, state: entry.state)
                        }
                        .swipeActions(edge: .leading, allowsFullSwipe: true) {
                            DoneButton { markDone(chore) }
                        }
                        .contextMenu {
                            DoneButton { markDone(chore) }
                        }
                        .accessibilityIdentifier("chore")
                    }
                }
                .listRowBackground(SbuTheme.surfaceRaised)
            } header: {
                Text("Attività")
            } footer: {
                if ranked.isEmpty {
                    Text("Nessuna attività. Aggiungine una: ci sono dei suggerimenti per questa stanza.")
                }
            }
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
        .background(SbuTheme.surface)
        .navigationTitle(room.name)
        .safeAreaInset(edge: .bottom) {
            SbuButton("Aggiungi attività", action: addChore)
                .accessibilityIdentifier("addChore")
                .padding(.horizontal, SbuTheme.space4)
                .padding(.vertical, SbuTheme.space2)
                .background(SbuTheme.surface)
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu("Stanza", systemImage: "ellipsis.circle") {
                    Button("Modifica stanza", systemImage: "pencil", action: edit)
                    Button("Duplica stanza", systemImage: "plus.square.on.square", action: duplicate)
                    Button("Elimina stanza", systemImage: "trash", role: .destructive, action: confirmDelete)
                }
                // In ink like the shell's gear: the accent belongs to the figure's full stop.
                .tint(SbuTheme.ink)
                .accessibilityIdentifier("roomMenu")
            }
        }
        .sheet(isPresented: $isAddingChore) {
            ChoreForm(room: room, chore: nil)
        }
        .sheet(isPresented: $isEditing) {
            RoomForm(room: room)
        }
        .confirmationDialog("Eliminare “\(room.name)”?", isPresented: $isConfirmingDelete, titleVisibility: .visible) {
            Button("Elimina stanza", role: .destructive, action: delete)
        } message: {
            Text("Le sue attività e il loro storico se ne vanno con lei.")
        }
        .sensoryFeedback(.success, trigger: doneCount)
    }

    private func markDone(_ chore: Chore) {
        chore.markDone(at: .now, in: modelContext)
        try? modelContext.save()
        clock.refresh()
        doneCount += 1
    }

    private func addChore() {
        isAddingChore = true
    }

    private func edit() {
        isEditing = true
    }

    private func duplicate() {
        Home.duplicate(room, in: modelContext)
        try? modelContext.save()
    }

    private func confirmDelete() {
        isConfirmingDelete = true
    }

    private func delete() {
        dismiss()
        Home.delete(room, in: modelContext)
        try? modelContext.save()
    }
}

#Preview("Light") {
    RoomViewPreview()
}

#Preview("Dark") {
    RoomViewPreview()
        .preferredColorScheme(.dark)
}

private struct RoomViewPreview: View {
    @Query(sort: \Room.order) private var rooms: [Room]

    var body: some View {
        NavigationStack {
            if let room = rooms.first {
                RoomView(room: room)
            }
        }
        .modelContainer(.preview)
        .environment(Clock())
        .tint(SbuTheme.accentTidy)
    }
}
