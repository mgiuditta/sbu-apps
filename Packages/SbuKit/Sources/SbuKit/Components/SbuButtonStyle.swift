import SwiftUI

/// Draws `SbuButton`: 50pt tall, full width, `radiusCard`, `headline`. Primary is `ink` with `paper`
/// text: buttons carry no color.
struct SbuButtonStyle: ButtonStyle {
    /// Minimum height from the Button component spec.
    private static let height: CGFloat = 50

    let kind: SbuButton.Kind

    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(SbuTheme.headline)
            .foregroundStyle(foreground)
            .padding(.horizontal, SbuTheme.space4)
            .frame(maxWidth: .infinity, minHeight: Self.height)
            .background(background, in: .rect(cornerRadius: SbuTheme.radiusCard))
            .contentShape(.rect(cornerRadius: SbuTheme.radiusCard))
            .opacity(configuration.isPressed ? 0.7 : 1)
    }

    private var foreground: AnyShapeStyle {
        guard isEnabled else { return AnyShapeStyle(SbuTheme.inkMuted) }

        return switch kind {
        case .primary: AnyShapeStyle(SbuTheme.paper)
        case .secondary: AnyShapeStyle(SbuTheme.ink)
        case .destructive: AnyShapeStyle(SbuTheme.danger)
        }
    }

    private var background: AnyShapeStyle {
        guard isEnabled else { return AnyShapeStyle(SbuTheme.surfaceSunken) }

        return kind == .primary ? AnyShapeStyle(SbuTheme.ink) : AnyShapeStyle(SbuTheme.surfaceRaised)
    }
}
