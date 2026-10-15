import PhotosUI
import SbuKit
import SwiftUI

/// The item form's photos: up to 8, from the camera or the library (no library permission needed),
/// in a row you can reorder from the menu of each one. The first is the one in lists.
struct PhotosSection: View {
    @Binding var photos: [PhotoDraft]

    @State private var picked: [PhotosPickerItem] = []
    @State private var isProcessing = false
    @State private var isShowingCamera = false
    @State private var isCameraDenied = false
    @Environment(\.openURL) private var openURL
    @ScaledMetric(relativeTo: .body) private var side: CGFloat = 72

    var body: some View {
        Section {
            if !photos.isEmpty || isProcessing {
                ScrollView(.horizontal) {
                    HStack(spacing: SbuTheme.space2) {
                        ForEach(Array(photos.enumerated()), id: \.element.id) { index, photo in
                            thumbnail(photo, index: index)
                        }
                        if isProcessing {
                            ProgressView()
                                .frame(width: side, height: side)
                        }
                    }
                    .padding(.vertical, SbuTheme.space1)
                }
                .scrollIndicators(.hidden)
            }
            if remaining > 0 {
                // Words only: beside a symbol the audit finds the title clipped (as in Sbu Habits).
                PhotosPicker(selection: $picked, maxSelectionCount: remaining, matching: .images) {
                    Text("Scegli dalle foto")
                }
                .accessibilityIdentifier("pickPhotos")
                if CameraPicker.isAvailable {
                    Button("Scatta una foto", action: openCamera)
                }
            }
        } header: {
            Text("Foto")
        } footer: {
            if remaining == 0 {
                Text("Hai aggiunto 8 foto, il massimo per un oggetto.")
            }
        }
        .onChange(of: picked) {
            Task { await load(picked) }
        }
        .fullScreenCover(isPresented: $isShowingCamera) {
            CameraPicker { photo in photos.append(photo) }
                .ignoresSafeArea()
        }
        .alert("Fotocamera non consentita", isPresented: $isCameraDenied) {
            Button("Apri Impostazioni", action: openSettings)
            Button("Annulla", role: .cancel) {}
        } message: {
            Text("Per fotografare gli oggetti consenti la fotocamera a Sbu Inventory nelle Impostazioni. Intanto puoi scegliere dalle foto.")
        }
    }

    private var remaining: Int {
        max(PhotoProcessor.maxPhotos - photos.count, 0)
    }

    private func thumbnail(_ photo: PhotoDraft, index: Int) -> some View {
        Menu {
            if index > 0 {
                Button("Metti per prima", systemImage: "arrow.left.to.line") { moveToFront(photo) }
            }
            Button("Rimuovi", systemImage: "trash", role: .destructive) { remove(photo) }
        } label: {
            Group {
                if let image = UIImage(data: photo.thumbnail) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                } else {
                    SbuTheme.surfaceSunken
                }
            }
            .frame(width: side, height: side)
            .clipShape(.rect(cornerRadius: SbuTheme.radiusSm))
        }
        .accessibilityLabel(Text("Foto \(index + 1) di \(photos.count)"))
        .accessibilityAction(named: Text("Rimuovi")) { remove(photo) }
    }

    private func openCamera() {
        Task {
            if await CameraAccess.request() {
                isShowingCamera = true
            } else {
                isCameraDenied = true
            }
        }
    }

    private func load(_ items: [PhotosPickerItem]) async {
        guard !items.isEmpty else { return }
        picked = []
        isProcessing = true
        for item in items {
            guard photos.count < PhotoProcessor.maxPhotos,
                  let data = try? await item.loadTransferable(type: Data.self),
                  let photo = await PhotoImport.process(data) else { continue }
            photos.append(photo)
        }
        isProcessing = false
    }

    private func moveToFront(_ photo: PhotoDraft) {
        photos.removeAll { $0.id == photo.id }
        photos.insert(photo, at: 0)
    }

    private func remove(_ photo: PhotoDraft) {
        photos.removeAll { $0.id == photo.id }
    }

    private func openSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) { openURL(url) }
    }
}

#Preview("Light") {
    @Previewable @State var photos: [PhotoDraft] = []
    Form {
        PhotosSection(photos: $photos)
    }
}

#Preview("Dark") {
    @Previewable @State var photos: [PhotoDraft] = []
    Form {
        PhotosSection(photos: $photos)
    }
    .preferredColorScheme(.dark)
}
