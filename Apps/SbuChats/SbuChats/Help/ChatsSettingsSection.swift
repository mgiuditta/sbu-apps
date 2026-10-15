import SbuKit
import SwiftUI

/// Sbu Chats' part of settings: the export how-to, and the names you said were you.
struct ChatsSettingsSection: View {
    let knownOwners: KnownOwners

    @State private var names: [String] = []

    var body: some View {
        Section {
            NavigationLink {
                ExportHelpView()
            } label: {
                Text("Come esportare una chat")
                    .font(SbuTheme.body)
                    .foregroundStyle(SbuTheme.ink)
            }
        }
        // Settings open as a sheet: read the names each time, they change with every "Chi sei?".
        .onAppear(perform: readNames)

        if !names.isEmpty {
            Section {
                ForEach(names, id: \.self) { name in
                    Text(verbatim: name)
                        .font(SbuTheme.body)
                        .foregroundStyle(SbuTheme.ink)
                }
                .onDelete(perform: forget)
            } header: {
                Text("Sei tu")
            } footer: {
                Text("In una chat nuova con uno di questi nomi Sbu Chats sa già chi sei. Scorri a sinistra per dimenticare un nome.")
            }
        }
    }

    private func readNames() {
        names = knownOwners.names
    }

    private func forget(_ offsets: IndexSet) {
        for index in offsets { knownOwners.forget(names[index]) }
        names = knownOwners.names
    }
}

#Preview("Light") {
    List { ChatsSettingsSection(knownOwners: KnownOwners(defaults: .standard)) }
}

#Preview("Dark") {
    List { ChatsSettingsSection(knownOwners: KnownOwners(defaults: .standard)) }
        .preferredColorScheme(.dark)
}
