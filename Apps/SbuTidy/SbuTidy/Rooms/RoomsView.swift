import SbuKit
import SwiftData
import SwiftUI

/// Tody's "Aree": every room with its state, in your order; add, duplicate, reorder, delete.
struct RoomsView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.calendar) private var calendar
    @Environment(Clock.self) private var clock
    @Query(sort: \Room.order) private var rooms: [Room]
    @State private var isAdding = false
    @State private var editing: Room?
    @State private var deleting: Room?

    var body: some View {
        let summaries = rooms.map { $0.summary(at: clock.now, calendar: calendar) }
        List {
            if !rooms.isEmpty {
                Section {
                    RoomsFigure(summaries: summaries)
                        .listRowInsets(EdgeInsets())
                        .listRowBackground(Color.clear)
                }
            }
            Section {
                ForEach(Array(zip(rooms, summaries)), id: \.0.id) { room, summary in
                    NavigationLink(value: room) {
                        RoomRow(name: room.name, kind: room.kind, summary: summary)
                    }
                    .swipeActions {
                        Button("Elimina", systemImage: "trash", role: .destructive) { deleting = room }
                        Button("Duplica", systemImage: "plus.square.on.square") { duplicate(room) }
                    }
                    .contextMenu {
                        Button("Modifica", systemImage: "pencil") { editing = room }
                        Button("Duplica", systemImage: "plus.square.on.square") { duplicate(room) }
                        Button("Elimina", systemImage: "trash", role: .destructive) { deleting = room }
                    }
                    .accessibilityIdentifier("room")
                }
                .onMove(perform: move)
                .listRowBackground(SbuTheme.surfaceRaised)
            } footer: {
                if rooms.isEmpty {
                    Text("Nessuna stanza. Aggiungi la prima.")
                }
            }
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
        .background(SbuTheme.surface)
        .navigationTitle("Stanze")
        .safeAreaInset(edge: .bottom) {
            SbuButton("Aggiungi stanza", action: add)
                .accessibilityIdentifier("addRoom")
                .padding(.horizontal, SbuTheme.space4)
                .padding(.vertical, SbuTheme.space2)
                .background(SbuTheme.surface)
        }
        .toolbar {
            if !rooms.isEmpty {
                EditButton()
                    .tint(SbuTheme.ink)
            }
        }
        .sheet(isPresented: $isAdding) {
            RoomForm(room: nil)
        }
        .sheet(item: $editing) { room in
            RoomForm(room: room)
        }
        .confirmationDialog(deleteTitle, isPresented: isDeleting, titleVisibility: .visible, presenting: deleting) { room in
            Button("Elimina stanza", role: .destructive) { delete(room) }
        } message: { _ in
            Text("Le sue attività e il loro storico se ne vanno con lei.")
        }
    }

    private var deleteTitle: LocalizedStringKey {
        "Eliminare “\(deleting?.name ?? "")”?"
    }

    private var isDeleting: Binding<Bool> {
        Binding { deleting != nil } set: { if !$0 { deleting = nil } }
    }

    private func add() {
        isAdding = true
    }

    private func duplicate(_ room: Room) {
        Home.duplicate(room, in: modelContext)
        try? modelContext.save()
    }

    private func move(from source: IndexSet, to destination: Int) {
        Home.move(rooms, from: source, to: destination)
        try? modelContext.save()
    }

    private func delete(_ room: Room) {
        Home.delete(room, in: modelContext)
        try? modelContext.save()
    }
}

#Preview("Light") {
    NavigationStack {
        RoomsView()
    }
    .modelContainer(.preview)
    .environment(Clock())
    .tint(SbuTheme.accentTidy)
}

#Preview("Dark") {
    NavigationStack {
        RoomsView()
    }
    .modelContainer(.preview)
    .environment(Clock())
    .tint(SbuTheme.accentTidy)
    .preferredColorScheme(.dark)
}
