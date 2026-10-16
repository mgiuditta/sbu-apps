import SwiftUI

/// The Sbu switch: a square ink track (50×28, radius 4) with a square knob (22, radius 2).
///
/// On is an `ink` track with a `paper` knob; off is a `line` track with a `surfaceRaised` knob. No
/// color: the only color of the screen is the full stop. It styles the system `Toggle`, and VoiceOver
/// and Voice Control get the system switch, so states and traits stay Apple's. The shells apply it to
/// every `Toggle`.
public struct SbuToggleStyle: ToggleStyle {
    public init() {}

    public func makeBody(configuration: Configuration) -> some View {
        SbuToggleBody(configuration: configuration)
    }
}

private struct SbuToggleBody: View {
    let configuration: ToggleStyleConfiguration

    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        Button {
            configuration.isOn.toggle()
        } label: {
            HStack(spacing: SbuTheme.space3) {
                configuration.label
                    .frame(maxWidth: .infinity, alignment: .leading)
                track
            }
            .contentShape(.rect)
        }
        .buttonStyle(.plain)
        .animation(SbuMotion.animation(SbuMotion.short, reduceMotion: reduceMotion), value: configuration.isOn)
        .accessibilityRepresentation {
            Toggle(isOn: configuration.$isOn) { configuration.label }
                .toggleStyle(.switch)
        }
    }

    private var track: some View {
        let inset = (SbuTheme.toggleHeight - SbuTheme.toggleKnob) / 2
        return RoundedRectangle(cornerRadius: SbuTheme.radiusControl)
            .fill(configuration.isOn ? ink : SbuTheme.line)
            .frame(width: SbuTheme.toggleWidth, height: SbuTheme.toggleHeight)
            .overlay(alignment: configuration.isOn ? .trailing : .leading) {
                RoundedRectangle(cornerRadius: SbuTheme.radiusKnob)
                    .fill(configuration.isOn ? SbuTheme.paper : SbuTheme.surfaceRaised)
                    .frame(width: SbuTheme.toggleKnob, height: SbuTheme.toggleKnob)
                    .padding(inset)
            }
    }

    /// Disabled controls fade to `inkMuted`, never to a color.
    private var ink: Color {
        isEnabled ? SbuTheme.ink : SbuTheme.inkMuted
    }
}

#Preview("Light") {
    SbuTogglePreview()
}

#Preview("Dark") {
    SbuTogglePreview()
        .preferredColorScheme(.dark)
}

#Preview("AX5") {
    SbuTogglePreview()
        .dynamicTypeSize(.accessibility5)
}

private struct SbuTogglePreview: View {
    @State private var lock = true
    @State private var sound = false

    var body: some View {
        Form {
            Toggle("Blocca lettura", isOn: $lock)
            Toggle("Suono quando in bolla", isOn: $sound)
            Toggle("Disattivato", isOn: .constant(true))
                .disabled(true)
        }
        .toggleStyle(SbuToggleStyle())
    }
}
