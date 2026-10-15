import SwiftUI

/// The folder picker pushed from the item form: choosing goes back to the form.
struct FolderChoice: View {
    @Binding var selection: Folder?

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        FolderPicker(selection: selection, choose: choose)
            .navigationTitle("Posizione")
            .navigationBarTitleDisplayMode(.inline)
    }

    private func choose(_ folder: Folder?) {
        selection = folder
        dismiss()
    }
}

#Preview("Light") {
    @Previewable @State var folder: Folder?
    NavigationStack {
        FolderChoice(selection: $folder)
    }
    .modelContainer(.preview)
}

#Preview("Dark") {
    @Previewable @State var folder: Folder?
    NavigationStack {
        FolderChoice(selection: $folder)
    }
    .modelContainer(.preview)
    .preferredColorScheme(.dark)
}
