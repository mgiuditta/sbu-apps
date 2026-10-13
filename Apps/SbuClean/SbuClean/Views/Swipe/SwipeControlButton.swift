import SbuKit
import SwiftUI

/// One round button with its word under it.
struct SwipeControlButton: View {
    enum Role {
        case trash
        case keep
        case secondary
    }

    let title: LocalizedStringKey
    let systemImage: String
    let role: Role
    let action: () -> Void

    @ScaledMetric(relativeTo: .body) private var mainSide = SbuTheme.controlRound
    @ScaledMetric(relativeTo: .body) private var smallSide = SbuTheme.controlRoundSm

    var body: some View {
        Button(action: action) {
            VStack(spacing: SbuTheme.space1) {
                Image(systemName: systemImage)
                    .font(.title3)
                    .fontWeight(.medium)
                    .foregroundStyle(glyph)
                    .frame(width: role == .secondary ? smallSide : mainSide, height: role == .secondary ? smallSide : mainSide)
                    .background(Circle().fill(fill))
                    .overlay(Circle().strokeBorder(SbuTheme.line, lineWidth: role == .keep ? 0 : SbuTheme.hairline))
                    .frame(height: mainSide)

                Text(title)
                    .font(SbuTheme.caption)
                    .foregroundStyle(SbuTheme.ink)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity)
            .contentShape(.rect)
        }
        .buttonStyle(.plain)
    }

    private var glyph: AnyShapeStyle {
        switch role {
        case .trash: AnyShapeStyle(SbuTheme.danger)
        case .keep: AnyShapeStyle(SbuTheme.onAccent)
        case .secondary: AnyShapeStyle(SbuTheme.ink)
        }
    }

    private var fill: AnyShapeStyle {
        role == .keep ? AnyShapeStyle(.tint) : AnyShapeStyle(SbuTheme.surfaceRaised)
    }
}

#Preview("Light") {
    SwipeControlButton(title: "Tieni", systemImage: "checkmark", role: .keep) {}
        .padding()
        .tint(SbuTheme.accentClean)
}

#Preview("Dark") {
    SwipeControlButton(title: "Elimina", systemImage: "trash", role: .trash) {}
        .padding()
        .tint(SbuTheme.accentClean)
        .preferredColorScheme(.dark)
}
