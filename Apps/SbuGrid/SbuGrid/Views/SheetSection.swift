import SbuKit
import SwiftUI

/// The sheet's format and orientation; for a custom sheet, its sides.
struct SheetSection: View {
    @Binding var paper: PaperSettings

    var body: some View {
        Section {
            Picker("Formato", selection: $paper.format) {
                ForEach(PaperFormat.allCases) { format in
                    Text(format.title).tag(format)
                }
            }
            // A sheet turns the figure from columns × rows into the side of a cell.
            .sbuAffectsFigure(paper.format)

            if paper.format.isSheet {
                Picker("Orientamento", selection: $paper.orientation) {
                    ForEach(PaperOrientation.allCases) { orientation in
                        Text(orientation.title).tag(orientation)
                    }
                }
            }

            if paper.format == .custom {
                LengthStepper(title: "Larghezza", value: $paper.customWidth, unit: paper.unit, range: paper.unit.sideRange)
                LengthStepper(title: "Altezza", value: $paper.customHeight, unit: paper.unit, range: paper.unit.sideRange)
            }
        } header: {
            Text("Foglio")
        } footer: {
            if let size = paper.size {
                Text(verbatim: LengthFormat.sheet(width: size.width, height: size.height, unit: paper.unit))
            } else {
                Text("Senza foglio ritagli la foto come vuoi e scegli righe e colonne in Griglia.")
            }
        }
    }
}

#Preview("Light") {
    @Previewable @State var paper = PaperSettings()
    Form {
        SheetSection(paper: $paper)
    }
}

#Preview("Dark") {
    @Previewable @State var paper = PaperSettings()
    Form {
        SheetSection(paper: $paper)
    }
    .preferredColorScheme(.dark)
}
