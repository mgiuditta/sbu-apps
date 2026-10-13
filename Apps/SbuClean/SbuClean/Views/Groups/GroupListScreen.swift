import SbuKit
import SwiftUI

/// Every group of one kind: the best shot first, the others selected for the bin. Tap a photo
/// to change its choice; "Elimina" sends the selection to the bin for the final review.
struct GroupListScreen: View {
    let model: CleanModel
    let kind: GroupKind

    @State private var showsBin = false

    var body: some View {
        let groups = model.groups(of: kind)
        let selected = model.selectedGroupMembers(of: kind)
        let bytes = model.bytes(of: selected)
        ScrollView {
            LazyVStack(alignment: .leading, spacing: SbuTheme.space6) {
                SpaceStat(label: "Selezionati", bytes: bytes, context: "\(selected.count) foto in \(groups.count) gruppi")

                ForEach(groups) { group in
                    GroupSection(model: model, group: group)
                }
            }
            .padding(SbuTheme.space4)
        }
        .background(SbuTheme.surface)
        .navigationTitle(kind == .duplicate ? "Duplicati" : "Simili")
        .navigationBarTitleDisplayMode(.inline)
        .bottomAction {
            SbuButton(DeleteTitle.forBytes(bytes)) {
                model.moveToTrash(selected)
                showsBin = true
            }
            .disabled(selected.isEmpty)
            .accessibilityIdentifier("bottomAction")
        }
        .navigationDestination(isPresented: $showsBin) {
            BinScreen(model: model)
        }
    }
}

#Preview("Light") {
    GroupListPreview()
}

#Preview("Dark") {
    GroupListPreview()
        .preferredColorScheme(.dark)
}

private struct GroupListPreview: View {
    @State private var model = CleanModel.preview

    var body: some View {
        NavigationStack {
            GroupListScreen(model: model, kind: .duplicate)
        }
        .tint(SbuTheme.accentClean)
        .task {
            await model.reload()
        }
    }
}
