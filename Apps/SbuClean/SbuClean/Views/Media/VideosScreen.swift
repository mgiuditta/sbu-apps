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
        Group {
            if videos.isEmpty {
                EmptyScreen(sentence: "Nessun video nella libreria.")
            } else {
                list(videos, bytes: bytes)
            }
        }
        .navigationTitle("Video")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(item: $playing) { video in
            VideoPreviewSheet(item: video)
        }
        .navigationDestination(isPresented: $showsBin) {
            BinScreen(model: model)
        }
    }

    private func list(_ videos: [MediaItem], bytes: Int64) -> some View {
        List {
            Section {
                SpaceStat(label: "Selezionati", bytes: bytes, context: "\(selection.count) di \(videos.count) video")
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
            }

            Section {
                ForEach(videos) { video in
                    VideoRow(item: video, isSelected: isSelected(video.id)) {
                        playing = video
                    }
                }
            } footer: {
                Text("Tocca un video per guardarlo. Scorrilo verso sinistra per comprimerlo.")
            }
            .listRowBackground(SbuTheme.surfaceRaised)
        }
        .listStyle(.insetGrouped)
        // The figure starts where it does on the other screens.
        .contentMargins(.top, SbuTheme.space4, for: .scrollContent)
        .scrollContentBackground(.hidden)
        .background(SbuTheme.paper)
        .bottomAction {
            SbuButton(DeleteTitle.forBytes(bytes)) {
                model.moveToTrash(videos.map(\.id).filter(selection.contains))
                selection = []
                showsBin = true
            }
            .disabled(selection.isEmpty)
            .accessibilityIdentifier("bottomAction")
        }
    }

    /// Whether one video is selected, as the binding its checkbox toggles.
    private func isSelected(_ id: String) -> Binding<Bool> {
        Binding {
            selection.contains(id)
        } set: { isOn in
            if isOn {
                selection.insert(id)
            } else {
                selection.remove(id)
            }
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
        .environment(\.sbuAccent, .clean)
        .task {
            await model.reload()
        }
    }
}
