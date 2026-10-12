import SwiftUI

/// Draws `SbuButton`: 50pt tall, full width, `radiusLg`, `headline`.
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
            .background(background, in: .rect(cornerRadius: SbuTheme.radiusLg))
            .contentShape(.rect(cornerRadius: SbuTheme.radiusLg))
            .opacity(configuration.isPressed ? 0.7 : 1)
    }

    private var foreground: AnyShapeStyle {
        guard isEnabled else { return AnyShapeStyle(SbuTheme.inkMuted) }

        return switch kind {
        case .primary: AnyShapeStyle(SbuTheme.onAccent)
        case .secondary: AnyShapeStyle(.tint)
        case .destructive: AnyShapeStyle(SbuTheme.danger)
        }
    }

    private var background: AnyShapeStyle {
        guard isEnabled else { return AnyShapeStyle(SbuTheme.surfaceSunken) }

        return kind == .primary ? AnyShapeStyle(.tint) : AnyShapeStyle(SbuTheme.surfaceRaised)
    }
}
