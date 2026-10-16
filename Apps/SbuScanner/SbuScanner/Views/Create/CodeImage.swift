import SbuKit
import SwiftUI

/// A code drawn sharp at any size, black on white so any scanner reads it, with its text for VoiceOver.
struct CodeImage: View {
    let graphic: CodeGraphic
    let label: String

    var body: some View {
        Image(uiImage: graphic.image(moduleSize: 4))
            .interpolation(.none)
            .resizable()
            .scaledToFit()
            .clipShape(.rect(cornerRadius: SbuTheme.radiusCard))
            .accessibilityLabel(Text("Codice: \(label)"))
    }
}

#Preview("Light") {
    if let graphic = CodeGraphic("https://sbu.dev", format: .qr) {
        CodeImage(graphic: graphic, label: "sbu.dev").padding()
    }
}

#Preview("Dark") {
    if let graphic = CodeGraphic("4006381333931", format: .ean13) {
        CodeImage(graphic: graphic, label: "4006381333931").padding()
            .preferredColorScheme(.dark)
    }
}
