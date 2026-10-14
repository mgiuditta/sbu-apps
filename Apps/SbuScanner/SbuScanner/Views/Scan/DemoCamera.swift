import SbuKit
import SwiftUI

/// The camera in screenshots and UI tests: a sample code on paper, read with a tap.
struct DemoCamera: View {
    let read: () -> Void

    var body: some View {
        Button(action: read) {
            if let graphic = CodeGraphic(DemoContent.scannedLink, format: .qr) {
                Image(uiImage: graphic.image(moduleSize: 8))
                    .interpolation(.none)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: 200)
                    .clipShape(.rect(cornerRadius: SbuTheme.radiusSm))
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Leggi il codice di esempio")
    }
}

#Preview("Light") {
    DemoCamera {}
}

#Preview("Dark") {
    DemoCamera {}
        .preferredColorScheme(.dark)
}
