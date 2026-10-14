import SwiftUI

/// Share a code as a PNG image or an SVG drawing.
struct CodeShareButtons: View {
    let graphic: CodeGraphic
    let name: String

    var body: some View {
        let fileName = name.isEmpty ? String(localized: "Codice") : name
        ShareLink(item: PNGFile(name: fileName, data: graphic.image(moduleSize: 16).pngData() ?? Data()), preview: SharePreview(fileName)) {
            Label("Condividi immagine", systemImage: "square.and.arrow.up")
        }
        ShareLink(item: SVGFile(name: fileName, svg: graphic.svg), preview: SharePreview(fileName)) {
            Label("Esporta SVG", systemImage: "doc.richtext")
        }
    }
}

#Preview("Light") {
    List { CodeShareButtons(graphic: CodeGraphic("ciao", format: .qr)!, name: "Ciao") }
}

#Preview("Dark") {
    List { CodeShareButtons(graphic: CodeGraphic("ciao", format: .qr)!, name: "Ciao") }
        .preferredColorScheme(.dark)
}
