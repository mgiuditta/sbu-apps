import SwiftData
import SwiftUI

/// The alert that names a new folder or renames one.
struct FolderNameAlert: ViewModifier {
    @Binding var naming: FolderNaming?

    @Environment(\.modelContext) private var context
    @State private var name = ""

    func body(content: Content) -> some View {
        content
            .alert(title, isPresented: isPresented) {
                TextField("Nome", text: $name)
                    .accessibilityIdentifier("folderName")
                Button("Annulla", role: .cancel) {}
                Button(confirmTitle, action: confirm)
            }
            .onChange(of: naming?.id) {
                if case let .rename(folder) = naming { name = folder.name } else { name = "" }
            }
    }

    private var title: Text {
        if case .rename = naming { Text("Rinomina cartella") } else { Text("Nuova cartella") }
    }

    private var confirmTitle: LocalizedStringKey {
        if case .rename = naming { "Rinomina" } else { "Crea" }
    }

    private var isPresented: Binding<Bool> {
        Binding { naming != nil } set: { if !$0 { naming = nil } }
    }

    private func confirm() {
        switch naming {
        case let .create(parent): InventoryActions.createFolder(named: name, in: parent, context: context)
        case let .rename(folder): InventoryActions.rename(folder, to: name, context: context)
        case nil: break
        }
    }
}

extension View {
    func folderNameAlert(_ naming: Binding<FolderNaming?>) -> some View {
        modifier(FolderNameAlert(naming: naming))
    }
}
