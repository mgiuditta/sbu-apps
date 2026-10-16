import SbuKit
import SwiftData
import SwiftUI

/// A code from the list, large enough to scan from the screen, with its text and the ways to share it.
struct CreatedCodeScreen: View {
    let code: CreatedCode
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var isConfirmingDelete = false

    var body: some View {
        let graphic = CodeGraphic(code.payload, format: code.format)
        let content = CodeContent(code.payload, symbology: code.format.symbology)
        List {
            Section {
                if let graphic {
                    CodeImage(graphic: graphic, label: content.summary)
                        .frame(maxWidth: graphic.isBarcode ? .infinity : 280)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, SbuTheme.space2)
                }
                LabeledContent("Tipo") { Text(code.kind.title) }
                LabeledContent("Formato") { Text(code.format.title) }
                LabeledContent("Creato", value: code.created.formatted(date: .abbreviated, time: .shortened))
            }
            Section("Contenuto") {
                Text(verbatim: code.payload)
                    .font(SbuTheme.footnote.monospaced())
                    .textSelection(.enabled)
            }
            if let graphic {
                Section {
                    CodeShareButtons(graphic: graphic, name: code.title)
                }
            }
            Section {
                Button("Elimina", systemImage: "trash", role: .destructive) { isConfirmingDelete = true }
                    .foregroundStyle(SbuTheme.danger)
            }
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
        .background(SbuTheme.paper)
        .navigationTitle(Text(verbatim: code.title))
        .navigationBarTitleDisplayMode(.inline)
        .confirmationDialog("Eliminare «\(code.title)»?", isPresented: $isConfirmingDelete, titleVisibility: .visible) {
            Button("Elimina", role: .destructive) {
                modelContext.delete(code)
                try? modelContext.save()
                dismiss()
            }
        }
    }
}

#Preview("Light") {
    NavigationStack { CreatedCodeScreen(code: CreatedCode(title: "Wi-Fi ospiti", kind: .wifi, format: .qr, payload: "WIFI:T:WPA;S:Ospiti;P:benvenuti;;")) }
}

#Preview("Dark") {
    NavigationStack { CreatedCodeScreen(code: CreatedCode(title: "Biscotti", kind: .product, format: .ean13, payload: "4006381333931")) }
        .preferredColorScheme(.dark)
}
