import PhotosUI
import SbuKit
import SwiftUI

/// The first screen, as in the original: pick the videos. Photos first, Files as in the
/// competitor. The settings follow on the navigation stack; the run and the result cover it.
struct MainView: View {
    let model: ShrinkModel

    @State private var isPickingPhotos = false
    @State private var isPickingFiles = false
    @State private var selection: [PhotosPickerItem] = []

    var body: some View {
        PickView(pickPhotos: pickPhotos, pickFiles: pickFiles)
            .photosPicker(isPresented: $isPickingPhotos, selection: $selection, matching: .videos, photoLibrary: .shared())
            .fileImporter(isPresented: $isPickingFiles, allowedContentTypes: [.movie], allowsMultipleSelection: true, onCompletion: importFiles)
            .onChange(of: selection) { _, items in
                addPicked(items)
            }
            .navigationDestination(isPresented: isShowingSettings) {
                CompressionSettingsScreen(model: model)
            }
            .fullScreenCover(isPresented: isShowingRun) {
                RunScreen(model: model)
            }
    }

    /// The settings stay under the run, so the stack is whole when the run goes back to them.
    private var isShowingSettings: Binding<Bool> {
        Binding {
            model.stage != .picking
        } set: { isShown in
            if !isShown { model.discard() }
        }
    }

    /// Only the model closes the run: Annulla before anything finished, or Fatto.
    private var isShowingRun: Binding<Bool> {
        Binding {
            model.stage == .compressing || model.stage == .done
        } set: { _ in }
    }

    private func pickPhotos() {
        isPickingPhotos = true
    }

    private func pickFiles() {
        isPickingFiles = true
    }

    private func addPicked(_ items: [PhotosPickerItem]) {
        guard !items.isEmpty else { return }
        model.pick(items.map(PendingVideo.init(item:)))
        selection = []
    }

    private func importFiles(_ result: Result<[URL], any Error>) {
        guard case .success(let urls) = result else { return }
        model.pick(urls.map(PendingVideo.init(file:)))
    }
}

#Preview("Light") {
    NavigationStack {
        MainView(model: .preview())
    }
}

#Preview("Dark") {
    NavigationStack {
        MainView(model: .preview())
    }
    .preferredColorScheme(.dark)
}
