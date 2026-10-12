import SbuKit
import SwiftUI

/// The SF Symbol of the phase, large, in the accent. Decorative: the phase name is in the context line.
struct MoonPhaseSymbol: View {
    let phase: MoonPhase

    /// Twice the figure, so the moon reads as the drawing and the number as the figure.
    @ScaledMetric(relativeTo: .largeTitle) private var size = SbuTheme.statHeroSize * 2

    var body: some View {
        Image(systemName: phase.systemImage)
            .font(.system(size: size, weight: .medium))
            .imageScale(.medium)
            .foregroundStyle(.tint)
            .contentTransition(.symbolEffect(.replace))
            .accessibilityHidden(true)
    }
}

#Preview("Light") {
    MoonPhaseSymbolPreview()
}

#Preview("Dark") {
    MoonPhaseSymbolPreview()
        .preferredColorScheme(.dark)
}

private struct MoonPhaseSymbolPreview: View {
    var body: some View {
        ScrollView {
            VStack(spacing: SbuTheme.space4) {
                ForEach(MoonPhase.allCases, id: \.self) { phase in
                    MoonPhaseSymbol(phase: phase)
                }
            }
        }
        .padding(SbuTheme.space4)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(SbuTheme.surface)
        .tint(SbuTheme.accentMoon)
    }
}
