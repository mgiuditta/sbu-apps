import SbuKit
import SwiftData
import SwiftUI

/// The folder of a code in the history, with a way to make a new one.
struct FolderPicker: View {
    @Bindable var record: ScanRecord
    @Query(sort: \ScanFolder.name) private var folders: [ScanFolder]
    @Environment(\.modelContext) private var modelContext
    @State private var isNaming = false
    @State private var newName = ""

    var body: some View {
        Picker("Cartella", selection: $record.folder) {
            Text("Nessuna").tag(ScanFolder?.none)
            ForEach(folders) { folder in
                Text(verbatim: folder.name).tag(Optional(folder))
            }
        }
        .onChange(of: record.folder) { try? modelContext.save() }
        Button("Nuova cartella", systemImage: "folder.badge.plus") {
            newName = ""
            isNaming = true
        }
        .alert("Nuova cartella", isPresented: $isNaming) {
            TextField("Nome", text: $newName)
            Button("Crea", action: createFolder)
                .disabled(newName.trimmingCharacters(in: .whitespaces).isEmpty)
            Button("Annulla", role: .cancel) {}
        }
    }

    private func createFolder() {
        let name = newName.trimmingCharacters(in: .whitespaces)
        guard !name.isEmpty else { return }
        let folder = ScanFolder(name: name)
        modelContext.insert(folder)
        record.folder = folder
        try? modelContext.save()
    }
}
