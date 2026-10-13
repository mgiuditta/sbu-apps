import SbuKit
import SwiftUI

/// The video compressor, laid out as in the Originale: the video to play, the size before and
/// after, three qualities, and the button that starts. The compressed copy is saved next to the
/// original, which goes to the bin only if you say so.
struct CompressScreen: View {
    let model: CleanModel
    let id: String

    @State private var quality = CompressionQuality.medium
    @State private var isCompressing = false
    @State private var isDone = false
    @State private var failed = false
    @State private var showsBin = false

    var body: some View {
        if let item = model.itemsByID[id] {
            let estimate = quality.estimatedBytes(duration: item.duration, originalBytes: item.bytes)
            ScrollView {
                VStack(alignment: .leading, spacing: SbuTheme.space4) {
                    VideoCardPlayer(item: item)
                        .aspectRatio(CGFloat(max(item.pixelWidth, 1)) / CGFloat(max(item.pixelHeight, 1)), contentMode: .fit)
                        .frame(maxHeight: 360)
                        .frame(maxWidth: .infinity)
                        .clipShape(.rect(cornerRadius: SbuTheme.radiusLg))

                    SpaceStat(label: "Dopo, circa", bytes: estimate, context: "Prima \(item.bytes.formatted(.byteCount(style: .file))), \(item.durationText)")

                    Picker("Qualità", selection: $quality) {
                        Text("Bassa").tag(CompressionQuality.low)
                        Text("Media").tag(CompressionQuality.medium)
                        Text("Alta").tag(CompressionQuality.high)
                    }
                    .pickerStyle(.segmented)

                    Text("La copia compressa va nella libreria con la stessa data e lo stesso luogo. L'originale resta finché non decidi.")
                        .font(SbuTheme.footnote)
                        .foregroundStyle(SbuTheme.inkMuted)
                }
                .padding(SbuTheme.space4)
            }
            .background(SbuTheme.surface)
            .navigationTitle("Comprimi")
            .navigationBarTitleDisplayMode(.inline)
            .bottomAction {
                SbuButton(isCompressing ? "Comprimo…" : "Avvia la compressione") {
                    compress(item)
                }
                .disabled(isCompressing || estimate >= item.bytes)
            }
            .confirmationDialog("Copia compressa salvata", isPresented: $isDone, titleVisibility: .visible) {
                Button("Metti l'originale nel cestino") {
                    model.moveToTrash([id])
                    showsBin = true
                }
                Button("Tieni l'originale", role: .cancel) {}
            } message: {
                Text("Vuoi mettere il video originale nel cestino? Lo rivedi prima di eliminarlo.")
            }
            .alert("Non è stato possibile comprimere", isPresented: $failed) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("Il video originale non è cambiato. Se è solo in iCloud, aprilo prima in Foto.")
            }
            .navigationDestination(isPresented: $showsBin) {
                BinScreen(model: model)
            }
        } else {
            Text("Il video non c'è più.")
                .font(SbuTheme.body)
                .foregroundStyle(SbuTheme.inkMuted)
        }
    }

    private func compress(_ item: MediaItem) {
        isCompressing = true
        Task {
            do {
                try await model.compress(item.id, quality: quality)
                isDone = true
            } catch {
                failed = true
            }
            isCompressing = false
        }
    }
}

#Preview("Light") {
    CompressPreview()
}

#Preview("Dark") {
    CompressPreview()
        .preferredColorScheme(.dark)
}

private struct CompressPreview: View {
    @State private var model = CleanModel.preview

    var body: some View {
        NavigationStack {
            CompressScreen(model: model, id: "video-0")
        }
        .tint(SbuTheme.accentClean)
        .task {
            await model.reload()
        }
    }
}
