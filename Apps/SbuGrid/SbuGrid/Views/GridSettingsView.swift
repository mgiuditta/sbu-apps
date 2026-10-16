import PhotosUI
import SbuKit
import SwiftUI

/// The grid settings, in DrawinGrid's order: a preview at the top, the photo, the line, the
/// columns and rows, the filter. Every change shows at once in the preview and on the photo.
struct GridSettingsView: View {
    @Environment(\.dismiss) private var dismiss

    @Bindable var model: GridModel

    @State private var selection: PhotosPickerItem?

    var body: some View {
        NavigationStack {
            Form {
                if let picture = model.picture {
                    Section {
                        GridPicture(image: picture, settings: model.settings, rule: model.cellRule)
                            .frame(maxWidth: .infinity, maxHeight: SbuTheme.controlRoundLg * 2)
                            .accessibilityElement()
                            .accessibilityLabel(Text("Anteprima della griglia"))
                            .accessibilityValue(Text(verbatim: model.count.spoken))
                            .accessibilityAddTraits(.isImage)
                    }
                    .listRowBackground(SbuTheme.surface)
                }

                Section {
                    PhotosPicker(selection: $selection, matching: .images, preferredItemEncoding: .current) {
                        Label("Cambia foto", systemImage: "photo.on.rectangle.angled")
                    }
                }
                .listRowBackground(SbuTheme.surfaceRaised)

                LineSection(settings: $model.settings)
                    .listRowBackground(SbuTheme.surfaceRaised)

                CellsSection(settings: $model.settings, count: model.count, cellRule: model.cellRule)
                    .listRowBackground(SbuTheme.surfaceRaised)

                Section {
                    Toggle("Bianco e nero", isOn: $model.settings.isBlackAndWhite)
                } footer: {
                    Text("Senza colori leggi meglio luci e ombre.")
                }
                .listRowBackground(SbuTheme.surfaceRaised)
            }
            .scrollContentBackground(.hidden)
            .background(SbuTheme.surface)
            .navigationTitle("Griglia")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Fine", action: close)
                }
            }
            .task(id: selection) {
                await open(selection)
            }
        }
    }

    private func close() {
        dismiss()
    }

    private func open(_ item: PhotosPickerItem?) async {
        guard let item else { return }
        await model.open(item)
        selection = nil
    }
}

#Preview("Light") {
    GridSettingsView(model: .forLaunch(.demo))
        .tint(SbuTheme.accentGrid)
}

#Preview("Dark") {
    GridSettingsView(model: .forLaunch(.demo))
        .tint(SbuTheme.accentGrid)
        .preferredColorScheme(.dark)
}
