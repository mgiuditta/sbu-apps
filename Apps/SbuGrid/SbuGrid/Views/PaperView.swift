import SbuKit
import SwiftUI

/// The sheet: its format and orientation, the unit, the side of a cell, and the crop of the
/// photo to the sheet's shape. Rows and columns come from here when there is a sheet.
struct PaperView: View {
    @Environment(\.dismiss) private var dismiss

    @Bindable var model: GridModel

    @State private var isCropping = false

    var body: some View {
        NavigationStack {
            Form {
                if let picture = model.picture {
                    Section {
                        GridPicture(image: picture, settings: model.settings, rule: model.cellRule)
                            .frame(maxWidth: .infinity, maxHeight: SbuTheme.controlRoundLg * 2)
                            .accessibilityElement()
                            .accessibilityLabel(Text("Anteprima del foglio"))
                            .accessibilityValue(Text(verbatim: model.count.spoken))
                            .accessibilityAddTraits(.isImage)
                    }
                    .listRowBackground(SbuTheme.surface)
                }

                SheetSection(paper: $model.paper)
                    .listRowBackground(SbuTheme.surfaceRaised)

                if model.paper.format.isSheet {
                    Section {
                        Picker("Unità", selection: $model.paper.unit) {
                            ForEach(LengthUnit.allCases) { unit in
                                Text(unit.title).tag(unit)
                            }
                        }

                        LengthStepper(title: "Lato della cella", value: $model.paper.cellLength, unit: model.paper.unit, range: model.paper.unit.cellRange)
                    } header: {
                        Text("Celle")
                    } footer: {
                        Text("Righe e colonne vengono dal foglio: \(GridCountFormatStyle().format(model.count)) celle. Se il foglio non ne contiene un numero intero, l'ultima riga e l'ultima colonna sono più strette, come quando righi il foglio dall'angolo.")
                    }
                    .listRowBackground(SbuTheme.surfaceRaised)
                }

                if model.photo != nil {
                    Section {
                        Button("Ritaglia la foto", systemImage: "crop", action: crop)
                    } footer: {
                        if model.paper.format.isSheet {
                            Text("Il ritaglio ha la forma del foglio: sposta e ridimensiona il riquadro sulla parte da disegnare.")
                        }
                    }
                    .listRowBackground(SbuTheme.surfaceRaised)
                }
            }
            .scrollContentBackground(.hidden)
            .background(SbuTheme.surface)
            .navigationTitle("Foglio")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Fine", action: close)
                }
            }
            .fullScreenCover(isPresented: $isCropping) {
                CropView(model: model)
            }
        }
    }

    private func close() {
        dismiss()
    }

    private func crop() {
        isCropping = true
    }
}

#Preview("Light") {
    PaperView(model: .forLaunch(.demo))
        .tint(SbuTheme.accentGrid)
}

#Preview("Dark") {
    PaperView(model: .forLaunch(.demo))
        .tint(SbuTheme.accentGrid)
        .preferredColorScheme(.dark)
}
