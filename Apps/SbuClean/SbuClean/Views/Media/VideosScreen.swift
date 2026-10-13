import SbuKit
import SwiftUI

/// Every video, the heaviest first, with size and length. Play one before deciding, compress
/// it, or select and send to the bin.
struct VideosScreen: View {
    let model: CleanModel

    @State private var selection: Set<String> = []
    @State private var playing: MediaItem?
    @State private var showsBin = false

    var body: some View {
        let videos = model.items(in: .videos).filter { !model.state.trash.contains($0.id) }
        let bytes = model.bytes(of: selection)
        List {
            Section {
                SpaceStat(label: "Selezionati", bytes: bytes, context: "\(selection.count) di \(videos.count) video")
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
            }

            Section {
                ForEach(videos) { video in
                    VideoRow(
                        item: video,
                        isSelected: selection.contains(video.id),
                        toggle: { toggle(video.id) },
                        play: { playing = video }
                    )
                }
            } footer: {
                if videos.isEmpty {
                    Text("Nessun video nella libreria.")
                } else {
                    Text("Tocca un video per guardarlo. Scorrilo verso sinistra per comprimerlo.")
                }
            }
            .listRowBackground(SbuTheme.surfaceRaised)
        }
        .listStyle(.insetGrouped)
        // The figure starts where it does on the other screens.
        .contentMargins(.top, SbuTheme.space4, for: .scrollContent)
        .scrollContentBackground(.hidden)
        .background(SbuTheme.surface)
        .navigationTitle("Video")
        .navigationBarTitleDisplayMode(.inline)
        .bottomAction {
            SbuButton(DeleteTitle.forBytes(bytes)) {
                model.moveToTrash(videos.map(\.id).filter(selection.contains))
                selection = []
                showsBin = true
            }
            .disabled(selection.isEmpty)
            .accessibilityIdentifier("bottomAction")
        }
        .sheet(item: $playing) { video in
            VideoPreviewSheet(item: video)
        }
        .navigationDestination(isPresented: $showsBin) {
            BinScreen(model: model)
        }
    }

    private func toggle(_ id: String) {
        if selection.contains(id) {
            selection.remove(id)
        } else {
            selection.insert(id)
        }
    }
}

#Preview("Light") {
    VideosPreview()
}

#Preview("Dark") {
    VideosPreview()
        .preferredColorScheme(.dark)
}

private struct VideosPreview: View {
    @State private var model = CleanModel.preview

    var body: some View {
        NavigationStack {
            VideosScreen(model: model)
        }
        .tint(SbuTheme.accentClean)
        .task {
            await model.reload()
        }
    }
}
