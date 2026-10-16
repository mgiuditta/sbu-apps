import SbuKit
import SwiftUI

/// The options the original lacks: a size to aim each video at, the codec, MP4, the audio.
/// Each with the one line that says what it costs.
struct AdvancedScreen: View {
    /// The target the switch proposes: the attachment limit of most mail services.
    static let suggestedTarget = 25.0

    @Binding var settings: CompressionSettings
    let targetFit: TargetFit?

    @FocusState private var isEditingTarget: Bool

    var body: some View {
        List {
            Section {
                Toggle("Dimensione massima", isOn: hasTarget)
                if settings.targetMegabytes != nil {
                    LabeledContent("MB per video") {
                        TextField("MB per video", value: target, format: .number.precision(.fractionLength(0...1)))
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .monospacedDigit()
                            .focused($isEditingTarget)
                    }
                }
            } footer: {
                TargetFooter(hasTarget: settings.targetMegabytes != nil, targetFit: targetFit)
            }
            .listRowBackground(SbuTheme.surfaceRaised)

            Section {
                Picker("Codec", selection: $settings.codec) {
                    Text("H.264").tag(VideoCodec.h264)
                    Text("HEVC").tag(VideoCodec.hevc)
                }
            } footer: {
                Text("H.264 si apre ovunque. HEVC pesa circa un terzo in meno, ma alcuni computer e siti non lo leggono.")
            }
            .listRowBackground(SbuTheme.surfaceRaised)

            Section {
                Toggle("Converti in MP4", isOn: $settings.convertsToMP4)
                Toggle("Togli l'audio", isOn: $settings.removesAudio)
            } footer: {
                Text("MP4 si carica ovunque; senza conversione il video resta nel formato dell'iPhone.")
            }
            .listRowBackground(SbuTheme.surfaceRaised)
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
        .scrollDismissesKeyboard(.interactively)
        .background(SbuTheme.surface)
        .navigationTitle("Avanzate")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Fine", action: endEditing)
            }
        }
    }

    /// The field never empties the target: clearing it keeps the last value until a new one.
    private var target: Binding<Double> {
        Binding {
            settings.targetMegabytes ?? Self.suggestedTarget
        } set: { settings.targetMegabytes = $0 }
    }

    private var hasTarget: Binding<Bool> {
        Binding {
            settings.targetMegabytes != nil
        } set: { isOn in
            settings.targetMegabytes = isOn ? Self.suggestedTarget : nil
        }
    }

    private func endEditing() {
        isEditingTarget = false
    }
}

#Preview("Light") {
    @Previewable @State var settings = CompressionSettings(targetMegabytes: 25)
    NavigationStack {
        AdvancedScreen(settings: $settings, targetFit: .fits)
    }
    .tint(SbuTheme.accentShrink)
}

#Preview("Dark") {
    @Previewable @State var settings = CompressionSettings(targetMegabytes: 2, codec: .hevc)
    NavigationStack {
        AdvancedScreen(settings: $settings, targetFit: .tooSmall)
    }
    .tint(SbuTheme.accentShrink)
    .preferredColorScheme(.dark)
}
