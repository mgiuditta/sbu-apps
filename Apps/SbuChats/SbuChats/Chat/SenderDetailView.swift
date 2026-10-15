import SbuKit
import SwiftUI

/// One person's numbers in a group chat.
struct SenderDetailView: View {
    let sender: SenderStatistics

    var body: some View {
        List {
            SenderSection(sender: sender, showsName: false)
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
        .background(SbuTheme.surface)
        .navigationTitle(Text(verbatim: sender.name))
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview("Light") {
    NavigationStack { SenderDetailView(sender: .preview) }
}

#Preview("Dark") {
    NavigationStack { SenderDetailView(sender: .preview) }
        .preferredColorScheme(.dark)
}
