import PhotosUI
import SbuKit
import SwiftUI

/// The grid screen: the photo with the grid and its tools, or, before any photo, the button to
/// choose one.
///
/// As in DrawinGrid: the menu at the top left (here settings), the photo filling the screen,
/// the grid tools beside it (here in a row under it), a new photo and the export at the top right.
struct MainView: View {
    @Environment(\.showSettings) private var showSettings

    @Bindable var model: GridModel

    @State private var isPicking = false
    @State private var selection: PhotosPickerItem?
    @State private var sheet: GridSheet?
    @State private var isFullScreen = false
    @State private var isTracing = false
    /// The Closure over the figure, once the gridded photo is saved to Photos.
    @State private var isClosing = false
    /// Saved from the export: the Closure plays once the export has slid away, on the figure.
    @State private var closesOnDismiss = false

    var body: some View {
        content
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Impostazioni", systemImage: "gearshape", action: showSettings.callAsFunction)
                }
                if model.photo != nil {
                    ToolbarItemGroup(placement: .topBarTrailing) {
                        Button("Cambia foto", systemImage: "photo.on.rectangle.angled", action: choosePhoto)
                        Button("Esporta", systemImage: "square.and.arrow.up", action: showExport)
                    }
                }
            }
            .photosPicker(isPresented: $isPicking, selection: $selection, matching: .images, preferredItemEncoding: .current)
            .task(id: selection) {
                await open(selection)
            }
            .overlay {
                if model.isOpening {
                    ProgressView()
                        .controlSize(.large)
                        .accessibilityLabel(Text("Apertura della foto"))
                }
            }
            .alert("Foto non aperta", isPresented: $model.isShowingOpenError, presenting: model.openError) { _ in
                Button("OK") {}
            } message: { error in
                Text(error.message)
            }
            .sheet(item: $sheet, onDismiss: closeIfSaved) { sheet in
                switch sheet {
                case .grid:
                    GridSettingsView(model: model)
                case .paper:
                    PaperView(model: model)
                case .export:
                    ExportView(model: model, onSaved: saved)
                }
            }
            .fullScreenCover(isPresented: $isFullScreen) {
                FullScreenView(model: model)
            }
            .fullScreenCover(isPresented: $isTracing) {
                TraceView(model: model)
            }
    }

    @ViewBuilder private var content: some View {
        if let picture = model.picture {
            GridScreen(model: model, picture: picture, actions: GridActions(showGrid: showGrid, showPaper: showPaper, showFullScreen: showFullScreen, showTrace: showTrace), isClosing: $isClosing)
        } else {
            EmptyPhotoView(choosePhoto: choosePhoto)
        }
    }
}

private extension MainView {
    func choosePhoto() {
        isPicking = true
    }

    func showGrid() {
        sheet = .grid
    }

    func showPaper() {
        sheet = .paper
    }

    func showExport() {
        sheet = .export
    }

    func showFullScreen() {
        isFullScreen = true
    }

    func showTrace() {
        isTracing = true
    }

    /// Saving to Photos ends the job: the export closes, and the figure says "Salvata".
    func saved() {
        closesOnDismiss = true
        sheet = nil
    }

    func closeIfSaved() {
        guard closesOnDismiss else { return }
        closesOnDismiss = false
        isClosing = true
    }

    func open(_ item: PhotosPickerItem?) async {
        guard let item else { return }
        await model.open(item)
        selection = nil
    }
}

#Preview("Light") {
    NavigationStack {
        MainView(model: .forLaunch(.demo))
    }
    .environment(\.sbuAccent, .grid)
}

#Preview("Dark") {
    NavigationStack {
        MainView(model: .forLaunch(.demo))
    }
    .environment(\.sbuAccent, .grid)
    .preferredColorScheme(.dark)
}

#Preview("Nessuna foto") {
    NavigationStack {
        MainView(model: .forLaunch(.empty))
    }
    .environment(\.sbuAccent, .grid)
}
