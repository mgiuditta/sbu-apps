import SbuKit
import SwiftUI

/// The user's albums, one at a time: tap one to swipe through it.
struct AlbumsScreen: View {
    let model: CleanModel

    @State private var hasLoaded = false

    var body: some View {
        Group {
            if hasLoaded && model.albums.isEmpty {
                EmptyScreen(sentence: "Non hai ancora album.")
            } else {
                list
            }
        }
        .navigationTitle("Album")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await model.loadAlbums()
            hasLoaded = true
        }
    }

    private var list: some View {
        List {
            Section {
                SpaceStat(label: "Nel cestino", bytes: model.trashBytes, context: "\(model.state.trash.count) elementi da rivedere")
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
            }

            Section {
                ForEach(model.albums) { album in
                    NavigationLink(value: Route.swipe(.album(album))) {
                        LabeledContent {
                            Text("\(album.count) elementi")
                                .foregroundStyle(SbuTheme.inkMuted)
                        } label: {
                            Text(verbatim: album.title)
                                .font(SbuTheme.headline)
                                .foregroundStyle(SbuTheme.ink)
                        }
                    }
                }
            } footer: {
                Text("Eliminare dal cestino toglie la foto dalla libreria e da tutti gli album, non solo da questo.")
            }
            .listRowBackground(SbuTheme.surfaceRaised)
        }
        .listStyle(.insetGrouped)
        // The figure starts where it does on the other screens.
        .contentMargins(.top, SbuTheme.space4, for: .scrollContent)
        .scrollContentBackground(.hidden)
        .background(SbuTheme.paper)
    }
}

#Preview("Light") {
    NavigationStack {
        AlbumsScreen(model: .preview)
    }
    .environment(\.sbuAccent, .clean)
}

#Preview("Dark") {
    NavigationStack {
        AlbumsScreen(model: .preview)
    }
    .environment(\.sbuAccent, .clean)
    .preferredColorScheme(.dark)
}
