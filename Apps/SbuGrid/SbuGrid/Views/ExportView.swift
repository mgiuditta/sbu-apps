import SbuKit
import SwiftUI

/// The export: the photo with its grid saved in Photos or shared at full resolution, and, with a
/// sheet, a PDF of the sheet's size to print at real scale.
struct ExportView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL

    let model: GridModel
    /// Called once the gridded photo is in Photos.
    var onSaved: () -> Void = {}

    @State private var files: ExportedFiles?
    @State private var failed = false
    @State private var saveState = SaveState.idle
    @State private var isShowingDenied = false

    var body: some View {
        NavigationStack {
            Form {
                if let files {
                    Section {
                        Image(decorative: files.image, scale: 1)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxWidth: .infinity, maxHeight: SbuTheme.controlRoundLg * 3)
                            .accessibilityLabel(Text("Foto con la griglia"))
                    }
                    .listRowBackground(SbuTheme.paper)

                    Section {
                        SaveToPhotosRow(state: saveState, action: save)
                        ShareLink(item: files.imageURL) {
                            Label("Condividi l'immagine", systemImage: "square.and.arrow.up")
                        }
                    } footer: {
                        Text("\(files.image.width) × \(files.image.height) pixel, come la foto.")
                    }
                    .listRowBackground(SbuTheme.surfaceRaised)

                    PDFSection(url: files.pdfURL, paper: model.paper)
                        .listRowBackground(SbuTheme.surfaceRaised)
                } else if failed {
                    Section {
                        Label("Esportazione non riuscita. Riprova.", systemImage: "exclamationmark.triangle")
                            .foregroundStyle(SbuTheme.danger)
                    }
                    .listRowBackground(SbuTheme.surfaceRaised)
                } else {
                    Section {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                            .accessibilityLabel(Text("Preparazione dell'esportazione"))
                    }
                    .listRowBackground(SbuTheme.paper)
                }
            }
            .scrollContentBackground(.hidden)
            .background(SbuTheme.paper)
            .navigationTitle("Esporta")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Fine", action: close)
                }
            }
            .alert("Foto non consentita", isPresented: $isShowingDenied) {
                Button("Apri Impostazioni", action: openSettings)
                Button("Annulla", role: .cancel) {}
            } message: {
                Text("Per salvare, consenti a Sbu Grid di aggiungere foto in Impostazioni. Sbu Grid aggiunge soltanto: non legge la tua libreria.")
            }
            .task {
                await prepare()
            }
        }
    }

    private func prepare() async {
        guard let picture = model.picture else {
            failed = true
            return
        }
        do {
            files = try await ExportedFiles.make(
                picture: picture,
                settings: model.settings,
                rule: model.cellRule,
                pageSize: model.paper.pageSize,
                in: GridExport.folder()
            )
        } catch {
            failed = true
        }
    }

    private func save() {
        guard let url = files?.imageURL else { return }
        saveState = .saving
        Task {
            do throws(ExportError) {
                try await PhotoLibrarySaver.save(fileAt: url)
                saveState = .saved
                onSaved()
            } catch {
                saveState = error == .photosDenied ? .idle : .failed
                isShowingDenied = error == .photosDenied
            }
        }
    }

    private func openSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            openURL(url)
        }
    }

    private func close() {
        dismiss()
    }
}

#Preview("Light") {
    ExportView(model: .forLaunch(.demo))
        .tint(SbuTheme.ink)
}

#Preview("Dark") {
    ExportView(model: .forLaunch(.demo))
        .tint(SbuTheme.ink)
        .preferredColorScheme(.dark)
}
