import SbuKit
import SwiftUI

/// Duplicates and similar photos at a glance: what is selected as the one figure, one card per
/// kind with its best shot, and "Elimina" at the bottom, which sends the selection to the bin
/// for the final review.
struct DuplicatesScreen: View {
    let model: CleanModel

    @State private var showsBin = false

    var body: some View {
        let selected = model.selectedGroupMembers()
        let bytes = model.bytes(of: selected)
        ScrollView {
            VStack(alignment: .leading, spacing: SbuTheme.space6) {
                SpaceStat(label: "Selezionati", bytes: bytes, context: "\(selected.count) foto da eliminare, la migliore di ogni gruppo resta")

                ScanStatusView(model: model)

                ForEach(GroupKind.allCases, id: \.self) { kind in
                    GroupKindCard(model: model, kind: kind)
                }
            }
            .padding(SbuTheme.space4)
        }
        .background(SbuTheme.surface)
        .navigationTitle("Duplicati e simili")
        .navigationBarTitleDisplayMode(.inline)
        .bottomAction {
            SbuButton(DeleteTitle.forBytes(bytes)) {
                model.moveToTrash(selected)
                showsBin = true
            }
            .disabled(selected.isEmpty)
        }
        .navigationDestination(isPresented: $showsBin) {
            BinScreen(model: model)
        }
    }
}

#Preview("Light") {
    DuplicatesPreview()
}

#Preview("Dark") {
    DuplicatesPreview()
        .preferredColorScheme(.dark)
}

private struct DuplicatesPreview: View {
    @State private var model = CleanModel.preview

    var body: some View {
        NavigationStack {
            DuplicatesScreen(model: model)
        }
        .tint(SbuTheme.accentClean)
        .task {
            await model.reload()
        }
    }
}
