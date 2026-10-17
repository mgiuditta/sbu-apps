import SbuKit
import SwiftUI

/// The moon as it looks, in the paper's own colors: the lit part is always the lighter one, so it
/// reads as light in both schemes. In light, `paper` lit and `inkMuted` in shadow; in dark, `ink`
/// lit and `paper` in shadow. An `inkMuted` hairline closes the disc. No accent: the full stop is
/// the only color. Decorative: the figure and the phase name already say it.
struct MoonDiscView: View {
    let disc: MoonDisc

    @Environment(\.colorScheme) private var colorScheme

    /// Six grid cells across: the drawing, smaller than the figure, so the number stays the figure.
    private let side = SbuTheme.gridCell * 6

    private var lit: Color { colorScheme == .dark ? SbuTheme.ink : SbuTheme.paper }
    private var shadow: Color { colorScheme == .dark ? SbuTheme.paper : SbuTheme.inkMuted }

    var body: some View {
        ZStack {
            Circle()
                .fill(shadow)

            MoonLitShape(disc: disc)
                .fill(lit)

            Circle()
                .strokeBorder(SbuTheme.inkMuted, lineWidth: SbuTheme.hairline)
        }
        .frame(width: side, height: side)
        .accessibilityHidden(true)
    }
}

#Preview("Light") {
    MoonDiscPreview()
}

#Preview("Dark") {
    MoonDiscPreview()
        .preferredColorScheme(.dark)
}

private struct MoonDiscPreview: View {
    private let discs: [MoonDisc] = [0, 0.15, 0.5, 0.85, 1].flatMap { illumination in
        [MoonDisc(illumination: illumination, isWaxing: true), MoonDisc(illumination: illumination, isWaxing: false)]
    }

    var body: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: SbuTheme.gridCell * 6))], spacing: SbuTheme.space4) {
                ForEach(discs.indices, id: \.self) { index in
                    MoonDiscView(disc: discs[index])
                }
            }
            .padding(SbuTheme.space4)
        }
        .background(SbuTheme.paper)
    }
}
