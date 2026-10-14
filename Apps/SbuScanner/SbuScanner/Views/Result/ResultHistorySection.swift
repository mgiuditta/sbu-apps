import SbuKit
import SwiftData
import SwiftUI

/// The code's place in the history: favourite, folder, delete.
struct ResultHistorySection: View {
    @Bindable var record: ScanRecord
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var isConfirmingDelete = false

    var body: some View {
        Section("Cronologia") {
            Toggle("Tra i preferiti", systemImage: "bookmark", isOn: $record.isFavorite)
            .onChange(of: record.isFavorite) { try? modelContext.save() }
            FolderPicker(record: record)
            Button("Elimina dalla cronologia", systemImage: "trash", role: .destructive) {
                isConfirmingDelete = true
            }
            .foregroundStyle(SbuTheme.danger)
            .confirmationDialog("Eliminare questo codice dalla cronologia?", isPresented: $isConfirmingDelete, titleVisibility: .visible) {
                Button("Elimina", role: .destructive, action: delete)
            }
        }
    }

    private func delete() {
        modelContext.delete(record)
        try? modelContext.save()
        dismiss()
    }
}
