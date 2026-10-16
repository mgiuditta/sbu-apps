import SbuKit
import SwiftUI

/// The PDF to print at real scale; without a sheet, where to choose one.
struct PDFSection: View {
    let url: URL?
    let paper: PaperSettings

    var body: some View {
        Section {
            if let url {
                ShareLink(item: url) {
                    Label("Condividi il PDF in scala", systemImage: "printer")
                }
            } else {
                Label("PDF in scala", systemImage: "printer")
                    .foregroundStyle(SbuTheme.inkMuted)
            }
        } footer: {
            if url != nil, let size = paper.size {
                Text("Un foglio di \(LengthFormat.sheet(width: size.width, height: size.height, unit: paper.unit)). Stampalo al 100%, senza adattarlo alla pagina: ogni cella misura \(LengthFormat.short(paper.cellLength, unit: paper.unit)).")
            } else {
                Text("Per un PDF in scala scegli un formato in Foglio.")
            }
        }
    }
}

#Preview("Light") {
    Form {
        PDFSection(url: nil, paper: PaperSettings())
    }
}

#Preview("Dark") {
    Form {
        PDFSection(url: nil, paper: PaperSettings())
    }
    .preferredColorScheme(.dark)
}
