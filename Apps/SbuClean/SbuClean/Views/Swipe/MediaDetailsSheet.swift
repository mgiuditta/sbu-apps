import SbuKit
import SwiftUI

/// What the long press on a card shows: date, size, resolution, camera, file. No place name,
/// which would need the network.
struct MediaDetailsSheet: View {
    let item: MediaItem

    @Environment(\.photoLibrary) private var library
    @Environment(\.dismiss) private var dismiss
    @State private var details: MediaDetails?

    var body: some View {
        NavigationStack {
            List {
                Section {
                    if let date = item.creationDate {
                        LabeledContent("Data", value: date.formatted(date: .long, time: .shortened))
                    }
                    LabeledContent("Dimensione", value: item.bytes.sizeText)
                    LabeledContent("Risoluzione") {
                        Text(verbatim: "\(item.pixelWidth.formatted(.number.grouping(.never))) × \(item.pixelHeight.formatted(.number.grouping(.never)))")
                    }
                    if item.kind == .video {
                        LabeledContent("Durata", value: item.durationText)
                    }
                    if let camera = details?.camera {
                        LabeledContent("Fotocamera", value: camera)
                    }
                    if let lens = details?.lens {
                        LabeledContent("Obiettivo", value: lens)
                    }
                    if let fileName = details?.fileName {
                        LabeledContent("File", value: fileName)
                    }
                }
                .listRowBackground(SbuTheme.surfaceRaised)
            }
            .listStyle(.insetGrouped)
            .scrollContentBackground(.hidden)
            .background(SbuTheme.paper)
            .navigationTitle("Dettagli")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Fine") {
                        dismiss()
                    }
                }
            }
        }
        .presentationDetents([.medium, .large])
        .task {
            details = await library.details(for: item.id)
        }
    }
}

#Preview("Light") {
    MediaDetailsSheet(item: MediaItem(id: "photo-1", creationDate: .now, kind: .photo, pixelWidth: 4032, pixelHeight: 3024, size: ItemSize(bytes: 3_200_000)))
}

#Preview("Dark") {
    MediaDetailsSheet(item: MediaItem(id: "video-0", creationDate: .now, kind: .video, pixelWidth: 1920, pixelHeight: 1080, duration: 83, size: ItemSize(bytes: 140_000_000)))
        .preferredColorScheme(.dark)
}
