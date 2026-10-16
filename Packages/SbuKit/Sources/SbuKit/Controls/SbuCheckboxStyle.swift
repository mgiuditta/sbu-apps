import SwiftUI

/// The Sbu checkbox: a 22 pt square with a 1.8 `ink` border and radius 3; checked, it fills with `ink`
/// and shows a `paper` check. The box comes before the label.
///
/// It styles the system `Toggle`, so VoiceOver gets the system on/off control.
public struct SbuCheckboxStyle: ToggleStyle {
    public init() {}

    public func makeBody(configuration: Configuration) -> some View {
        SbuCheckboxBody(configuration: configuration)
    }
}

private struct SbuCheckboxBody: View {
    let configuration: ToggleStyleConfiguration

    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        Button {
            configuration.isOn.toggle()
        } label: {
            HStack(spacing: SbuTheme.space3) {
                box
                configuration.label
                    .frame(maxWidth: .infinity, alignment: .leading)
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

    private var box: some View {
        let shape = RoundedRectangle(cornerRadius: SbuTheme.radiusCheckbox)
        return shape
            .fill(configuration.isOn ? ink : .clear)
            .overlay {
                shape.strokeBorder(ink, lineWidth: SbuTheme.checkboxStroke)
            }
            .overlay {
                if configuration.isOn {
                    Image(systemName: "checkmark")
                        .resizable()
                        .scaledToFit()
                        .fontWeight(.bold)
                        .foregroundStyle(SbuTheme.paper)
                        .padding(SbuTheme.space1 + SbuTheme.hairline)
                }
            }
            .frame(width: SbuTheme.checkbox, height: SbuTheme.checkbox)
    }

    /// Disabled controls fade to `inkMuted`, never to a color.
    private var ink: Color {
        isEnabled ? SbuTheme.ink : SbuTheme.inkMuted
    }
}

#Preview("Light") {
    SbuCheckboxPreview()
}

#Preview("Dark") {
    SbuCheckboxPreview()
        .preferredColorScheme(.dark)
}

#Preview("AX5") {
    SbuCheckboxPreview()
        .dynamicTypeSize(.accessibility5)
}

private struct SbuCheckboxPreview: View {
    @State private var read = true
    @State private var walk = false

    var body: some View {
        List {
            Toggle("Leggere 20 minuti", isOn: $read)
            Toggle("Camminare", isOn: $walk)
        }
        .toggleStyle(SbuCheckboxStyle())
    }
}
