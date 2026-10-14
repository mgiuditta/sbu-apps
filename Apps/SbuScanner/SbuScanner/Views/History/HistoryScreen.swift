import SbuKit
import SwiftData
import SwiftUI

/// Every code read, newest first: search, favourites, folders, CSV.
struct HistoryScreen: View {
    @Query(sort: \ScanRecord.date, order: .reverse) private var records: [ScanRecord]
    @Query(sort: \ScanFolder.name) private var folders: [ScanFolder]
    @Environment(\.modelContext) private var modelContext
    @State private var search = ""
    @State private var filter = HistoryFilter.all
    @State private var isConfirmingClear = false
    @State private var isConfirmingFolderDelete = false

    var body: some View {
        let shown = records.filter { filter.includes($0) && matches($0) }
        List {
            ForEach(shown) { record in
                NavigationLink(value: ScannerRoute.record(record)) {
                    HistoryRow(record: record)
                }
            }
            .onDelete { offsets in
                offsets.map { shown[$0] }.forEach(modelContext.delete)
                try? modelContext.save()
            }
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
        .background(SbuTheme.surface)
        .overlay {
            if shown.isEmpty {
                if search.isEmpty {
                    ContentUnavailableView("Nessun codice", systemImage: "clock.arrow.circlepath", description: Text(emptyMessage))
                } else {
                    ContentUnavailableView.search(text: search)
                }
            }
        }
        .navigationTitle("Cronologia")
        .navigationBarTitleDisplayMode(.inline)
        .searchable(text: $search, prompt: Text("Cerca nei codici"))
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Picker("Mostra", selection: $filter) {
                        Text("Tutti").tag(HistoryFilter.all)
                        Label("Preferiti", systemImage: "bookmark").tag(HistoryFilter.favorites)
                        ForEach(folders) { folder in
                            Label(folder.name, systemImage: "folder").tag(HistoryFilter.folder(folder))
                        }
                    }
                    Section {
                        ShareLink(item: export, preview: SharePreview(Text("Cronologia Sbu Scanner"))) {
                            Label("Esporta CSV", systemImage: "square.and.arrow.up")
                        }
                        .disabled(records.isEmpty)
                        if case .folder = filter {
                            Button("Elimina cartella", systemImage: "folder.badge.minus", role: .destructive) {
                                isConfirmingFolderDelete = true
                            }
                        }
                        Button("Cancella cronologia", systemImage: "trash", role: .destructive) {
                            isConfirmingClear = true
                        }
                        .disabled(records.isEmpty)
                    }
                } label: {
                    Label("Opzioni", systemImage: "line.3.horizontal.decrease.circle")
                }
                .tint(SbuTheme.ink)
            }
        }
        .confirmationDialog("Cancellare tutta la cronologia?", isPresented: $isConfirmingClear, titleVisibility: .visible) {
            Button("Cancella cronologia", role: .destructive, action: clear)
        } message: {
            Text("I codici letti spariscono da questo iPhone. Le cartelle e i codici creati restano.")
        }
        .confirmationDialog("Eliminare la cartella?", isPresented: $isConfirmingFolderDelete, titleVisibility: .visible) {
            Button("Elimina cartella", role: .destructive, action: deleteFolder)
        } message: {
            Text("I suoi codici restano nella cronologia, senza cartella.")
        }
    }

    private var emptyMessage: LocalizedStringKey {
        switch filter {
        case .all: "I codici che leggi compaiono qui, solo su questo iPhone."
        case .favorites: "Nessun codice tra i preferiti."
        case .folder: "Nessun codice in questa cartella."
        }
    }

    private func matches(_ record: ScanRecord) -> Bool {
        search.isEmpty || record.raw.localizedStandardContains(search) || record.content.summary.localizedStandardContains(search)
    }

    private var export: HistoryExport {
        HistoryExport(
            rows: records.map { record in
                HistoryCSV.Row(
                    date: record.date,
                    kind: String(localized: record.content.kind.title),
                    symbology: record.symbology.name,
                    folder: record.folder?.name ?? "",
                    isFavorite: record.isFavorite,
                    content: record.raw
                )
            },
            header: [String(localized: "Data"), String(localized: "Tipo"), String(localized: "Codice"), String(localized: "Cartella"), String(localized: "Preferito"), String(localized: "Contenuto")]
        )
    }

    private func clear() {
        records.forEach(modelContext.delete)
        try? modelContext.save()
    }

    private func deleteFolder() {
        guard case let .folder(folder) = filter else { return }
        filter = .all
        modelContext.delete(folder)
        try? modelContext.save()
    }
}

#Preview("Light") {
    NavigationStack { HistoryScreen() }
        .modelContainer(.preview)
}

#Preview("Dark") {
    NavigationStack { HistoryScreen() }
        .modelContainer(.preview)
        .preferredColorScheme(.dark)
}
