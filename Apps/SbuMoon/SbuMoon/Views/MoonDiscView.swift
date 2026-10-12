import SbuKit
import SwiftUI

/// The moon as it looks: the lit part in the accent, the dark part sunken paper with a hairline
/// in the accent. Decorative: the figure and the phase name already say it.
struct MoonDiscView: View {
    let disc: MoonDisc

    /// Twice the figure, so the moon reads as the drawing and the number as the figure.
    @ScaledMetric(relativeTo: .largeTitle) private var side = SbuTheme.statHeroSize * 2

    var body: some View {
        ZStack {
            Circle()
                .fill(SbuTheme.surfaceSunken)

            MoonLitShape(disc: disc)
                .fill(.tint)

            Circle()
                .strokeBorder(.tint, lineWidth: SbuTheme.hairline)
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
            LazyVGrid(columns: [GridItem(.adaptive(minimum: SbuTheme.statHeroSize * 2))], spacing: SbuTheme.space4) {
                ForEach(discs.indices, id: \.self) { index in
                    MoonDiscView(disc: discs[index])
                }
            }
            .padding(SbuTheme.space4)
        }
        .background(SbuTheme.surface)
        .tint(SbuTheme.accentMoon)
    }
}
