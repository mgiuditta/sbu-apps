import SwiftUI

/// Draws a pill on the tool screen: `subheadline` in `onField` on `fieldControl`, `radiusPill`.
///
/// A selected pill takes `fieldControlActive` and weight 600, so its state reads without color.
/// Put up to five pills in the pills slot of `SbuToolField`; with more, use a system segmented
/// picker.
public struct SbuFieldPillStyle: ButtonStyle {
    /// Minimum tap target from the Human Interface Guidelines.
    private static let minHeight: CGFloat = 44

    private let isSelected: Bool

    @Environment(\.isEnabled) private var isEnabled

    /// Creates the pill style.
    /// - Parameter isSelected: Whether the pill is the chosen option; `false` for action pills.
    public init(isSelected: Bool = false) {
        self.isSelected = isSelected
    }

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(SbuTheme.subheadline.weight(isSelected ? .semibold : .regular))
            .foregroundStyle(isEnabled ? SbuTheme.onField : SbuTheme.onFieldMuted)
            .padding(.vertical, SbuTheme.space2)
            .padding(.horizontal, SbuTheme.space4)
            .frame(minHeight: Self.minHeight)
            .background(
                isSelected || configuration.isPressed ? SbuTheme.fieldControlActive : SbuTheme.fieldControl,
                in: .rect(cornerRadius: SbuTheme.radiusPill)
            )
            .contentShape(.rect(cornerRadius: SbuTheme.radiusPill))
            .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

#Preview("Light") {
    SbuFieldPillStylePreview()
}

#Preview("Dark") {
    SbuFieldPillStylePreview()
        .preferredColorScheme(.dark)
}

private struct SbuFieldPillStylePreview: View {
    var body: some View {
        VStack(spacing: SbuTheme.space4) {
            HStack(spacing: SbuTheme.space2) {
                Button("Bolla") {}
                    .buttonStyle(SbuFieldPillStyle(isSelected: true))
                Button("Barra") {}
                    .buttonStyle(SbuFieldPillStyle())
            }

            Button("Calibra") {}
                .buttonStyle(SbuFieldPillStyle())

            Button("Calibra") {}
                .buttonStyle(SbuFieldPillStyle())
                .disabled(true)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(SbuTheme.fieldLevel)
        .environment(\.colorScheme, .dark)
    }
}
