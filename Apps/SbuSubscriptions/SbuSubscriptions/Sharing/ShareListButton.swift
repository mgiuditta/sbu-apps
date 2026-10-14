import SbuKit
import SwiftUI

/// Shares one list through iCloud, read only, or manages who has it once it's shared.
struct ShareListButton: View {
    let list: SubscriptionList
    let sharing: ListSharing

    @State private var isPreparing = false

    var body: some View {
        Button {
            Task { await share() }
        } label: {
            Label("Condividi \(list.name)", systemImage: sharing.isShared(list) ? "person.2.fill" : "person.crop.circle.badge.plus")
                .labelStyle(.iconOnly)
                .fontWeight(.medium)
                .frame(minWidth: 44, minHeight: 44)
                .contentShape(.rect)
        }
        .buttonStyle(.borderless)
        .disabled(!sharing.isAvailable || isPreparing || list.name.isEmpty)
        .overlay { if isPreparing { ProgressView() } }
    }

    private func share() async {
        isPreparing = true
        defer { isPreparing = false }
        guard let share = try? await sharing.prepareShare(of: list) else { return }
        let id = list.uuid
        CloudSharingPresenter.present(share, title: list.name) { stopped in
            Task { await sharing.sharingDidChange(for: id, stopped: stopped) }
        }
    }
}
