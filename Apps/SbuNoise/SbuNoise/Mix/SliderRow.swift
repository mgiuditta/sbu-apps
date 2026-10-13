import SwiftUI

/// A form row with the name above the slider; VoiceOver reads the slider's own label once.
struct SliderRow<Content: View>: View {
    let title: LocalizedStringKey
    @ViewBuilder let slider: Content

    init(_ title: LocalizedStringKey, @ViewBuilder slider: () -> Content) {
        self.title = title
        self.slider = slider()
    }

    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .accessibilityHidden(true)
            slider
        }
    }
}

#Preview("Light") {
    Form { SliderRow("Volume") { Slider(value: .constant(0.6)) { Text("Volume") } } }
}

#Preview("Dark") {
    Form { SliderRow("Varianza") { Slider(value: .constant(0.2)) { Text("Varianza") } } }
        .preferredColorScheme(.dark)
}
