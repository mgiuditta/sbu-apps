import SbuKit
import SwiftData
import SwiftUI

/// The item form's label: the barcode or QR already on the item, to find it again with a scan.
struct LabelSection: View {
    @Binding var code: String?
    /// The item being edited, so its own label doesn't count as taken.
    let item: Item?

    @Environment(\.modelContext) private var context
    @State private var isScanning = false

    var body: some View {
        Section {
            if let code {
                LabeledContent("Codice", value: code)
                Button("Rimuovi l'etichetta", role: .destructive) { self.code = nil }
            } else {
                Button("Collega un'etichetta") { isScanning = true }
                    .accessibilityIdentifier("linkLabel")
            }
        } header: {
            Text("Etichetta")
        } footer: {
            Text(footer)
        }
        .sheet(isPresented: $isScanning) {
            ScanLabelSheet(purpose: .link) { code = $0 }
        }
    }

    private var footer: LocalizedStringKey {
        guard let code else {
            return "Un codice a barre o un QR già sull'oggetto: lo ritrovi inquadrandolo con Trova dall'etichetta."
        }
        switch LabelLinker.owner(of: code, in: context) {
        case let .item(owner) where owner != item:
            return "Questa etichetta è di «\(owner.name)»: salvando passa a questo oggetto."
        case let .folder(owner):
            return "Questa etichetta è della cartella «\(owner.name)»: salvando passa a questo oggetto."
        default:
            return "La scansione di questa etichetta apre l'oggetto."
        }
    }
}

#Preview("Light") {
    @Previewable @State var code: String?
    Form {
        LabelSection(code: $code, item: nil)
    }
    .modelContainer(.preview)
}

#Preview("Dark") {
    @Previewable @State var code: String? = "8001234567890"
    Form {
        LabelSection(code: $code, item: nil)
    }
    .modelContainer(.preview)
    .preferredColorScheme(.dark)
}
