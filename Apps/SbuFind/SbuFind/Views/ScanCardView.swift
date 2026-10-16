import SbuKit
import SwiftUI

/// The card at the bottom of the list while a scan starts, as in Find Air: "Ricerca…", a close
/// button, and a disc that breathes like a radar. The list stays usable above it.
struct ScanCardView: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    let close: () -> Void

    var body: some View {
        VStack(spacing: SbuTheme.space4) {
            // The title centred between the close button and a space as wide, as in Find Air.
            HStack(spacing: 0) {
                Color.clear
                    .frame(width: SbuTheme.controlRoundSm, height: 1)

                Text("Ricerca…")
                    .font(SbuTheme.title2)
                    .foregroundStyle(SbuTheme.ink)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                    .accessibilityAddTraits(.isHeader)

                Button("Chiudi", systemImage: "xmark.circle.fill", action: close)
                    .labelStyle(.iconOnly)
                    .font(SbuTheme.title2)
                    .foregroundStyle(SbuTheme.inkMuted)
                    .frame(minWidth: SbuTheme.controlRoundSm, minHeight: SbuTheme.controlRoundSm)
                    .contentShape(.rect)
            }

            // At the accessibility sizes only the title and the button: the list keeps the screen.
            if !dynamicTypeSize.isAccessibilitySize {
                ScanDisc()
                    .frame(height: 132)

                Text("Sbu Find ascolta i dispositivi Bluetooth vicini.")
                    .font(SbuTheme.footnote)
                    .foregroundStyle(SbuTheme.inkMuted)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(.horizontal, SbuTheme.space4)
        .padding(.top, SbuTheme.space4)
        .padding(.bottom, SbuTheme.space2)
        .frame(maxWidth: .infinity)
        .background(SbuTheme.surfaceRaised, in: .rect(cornerRadius: SbuTheme.radiusXl))
        .overlay {
            RoundedRectangle(cornerRadius: SbuTheme.radiusXl)
                .strokeBorder(SbuTheme.line, lineWidth: SbuTheme.hairline)
        }
        .padding(.horizontal, SbuTheme.space4)
        .accessibilityElement(children: .contain)
    }
}

#Preview("Light") {
    VStack {
        Spacer()
        ScanCardView {}
    }
    .background(SbuTheme.surface)
    .tint(SbuTheme.accentFind)
}

#Preview("Dark") {
    VStack {
        Spacer()
        ScanCardView {}
    }
    .background(SbuTheme.surface)
    .tint(SbuTheme.accentFind)
    .preferredColorScheme(.dark)
}
