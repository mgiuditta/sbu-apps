import SbuKit
import SwiftUI

/// Live Photos turned into still photos: the space of the video part as the figure, before and
/// after for each one. The still copy keeps date, place and favourite; the original goes to the
/// bin for the final review.
struct LivePhotosScreen: View {
    let model: CleanModel

    @State private var selection: Set<String> = []
    @State private var isConverting = false
    @State private var showsBin = false

    private let columns = [GridItem(.adaptive(minimum: 150), spacing: SbuTheme.space2)]

    var body: some View {
        let photos = model.items(in: .livePhotos).filter { !model.state.trash.contains($0.id) }
        let saved = photos.filter { selection.contains($0.id) }.reduce(0) { $0 + ($1.size?.pairedVideoBytes ?? 0) }
        ScrollView {
            VStack(alignment: .leading, spacing: SbuTheme.space4) {
                SpaceStat(label: "Spazio liberabile", bytes: saved, context: "\(selection.count) di \(photos.count) Live Photo")

                Text("Sbu Clean salva una foto fissa con la stessa data, lo stesso luogo e la stessa preferita, e mette la Live Photo nel cestino. Perdi solo il movimento.")
                    .font(SbuTheme.footnote)
                    .foregroundStyle(SbuTheme.inkMuted)

                LazyVGrid(columns: columns, spacing: SbuTheme.space2) {
                    ForEach(photos) { photo in
                        LivePhotoTile(item: photo, isSelected: selection.contains(photo.id)) {
                            toggle(photo.id)
                        }
                    }
                }
            }
            .padding(SbuTheme.space4)
        }
        .background(SbuTheme.surface)
        .navigationTitle("Live Photo")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(selection.count == photos.count && !photos.isEmpty ? "Deseleziona tutto" : "Seleziona tutto") {
                    selection = selection.count == photos.count ? [] : Set(photos.map(\.id))
                }
                .disabled(photos.isEmpty)
            }
        }
        .bottomAction {
            SbuButton("Converti \(selection.count) in foto fisse", action: convert)
                .disabled(selection.isEmpty || isConverting)
                .overlay {
                    if isConverting {
                        ProgressView()
                    }
                }
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

    private func convert() {
        isConverting = true
        Task {
            let converted = await model.convertLivePhotos(Array(selection))
            selection = []
            isConverting = false
            if converted > 0 {
                showsBin = true
            }
        }
    }
}

#Preview("Light") {
    LivePhotosPreview()
}

#Preview("Dark") {
    LivePhotosPreview()
        .preferredColorScheme(.dark)
}

private struct LivePhotosPreview: View {
    @State private var model = CleanModel.preview

    var body: some View {
        NavigationStack {
            LivePhotosScreen(model: model)
        }
        .tint(SbuTheme.accentClean)
        .task {
            await model.reload()
        }
    }
}
