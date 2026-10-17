import SbuKit
import SwiftUI

/// Tapping a sound on the pad: its volume, pitch, variance and speed, changed live; reset and delete.
struct MixLayerSheet: View {
    let soundName: LocalizedStringResource
    @Binding var layer: MixLayer
    let onDelete: () -> Void

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    SliderRow("Volume") {
                        Slider(value: $layer.volume, in: 0...1) { Text("Volume") }
                    }
                    SliderRow("Tono") {
                        Slider(value: $layer.pitch, in: -1200...1200, step: 100) { Text("Tono") }
                            .accessibilityValue(Text(semitones))
                    }
                    SliderRow("Varianza") {
                        Slider(value: $layer.variance, in: 0...1) { Text("Varianza") }
                    }
                    SliderRow("Velocità") {
                        Slider(value: $layer.speed, in: 0...1) { Text("Velocità") }
                    }
                    .disabled(layer.variance == 0)
                } footer: {
                    Text("Con la varianza il suono si muove da solo attorno al suo posto; la velocità dice quanto in fretta.")
                }
                Section {
                    Button("Ripristina") { layer = layer.reset() }
                        .disabled(layer == layer.reset())
                    SbuButton("Elimina dal mix", kind: .destructive) {
                        onDelete()
                        dismiss()
                    }
                }
            }
            .navigationTitle(Text(soundName))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Fine") { dismiss() }
                }
            }
        }
    }

    /// "+2", "-5", "0": the pitch in semitones, for VoiceOver.
    private var semitones: String {
        (layer.pitch / 100).formatted(.number.precision(.fractionLength(0)).sign(strategy: .always(includingZero: false)))
    }
}

#Preview("Light") {
    MixLayerSheet(soundName: "Rumore rosa", layer: .constant(MixLayer(soundID: "noise.pink", position: .center, variance: 0.3))) {}
}

#Preview("Dark") {
    MixLayerSheet(soundName: "Rumore rosa", layer: .constant(MixLayer(soundID: "noise.pink", position: .center))) {}
        .preferredColorScheme(.dark)
}
