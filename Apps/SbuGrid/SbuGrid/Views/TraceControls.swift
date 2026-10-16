import SbuKit
import SwiftUI

/// The photo's opacity over the camera and the lock, on a strip of paper at the bottom.
struct TraceControls: View {
    @Binding var opacity: Double
    @Binding var isLocked: Bool

    var body: some View {
        VStack(spacing: SbuTheme.space3) {
            SliderRow(
                title: "Foto",
                value: $opacity,
                range: TraceSettings.opacityRange,
                step: TraceSettings.opacityStep,
                formatted: opacity.formatted(.percent.precision(.fractionLength(0)))
            )

            Button(isLocked ? "Sblocca la foto" : "Blocca la foto", systemImage: isLocked ? "lock" : "lock.open", action: toggleLock)
                .buttonStyle(SbuFieldPillStyle(isSelected: isLocked))
        }
        .font(SbuTheme.body)
        .foregroundStyle(SbuTheme.ink)
        .padding(SbuTheme.space4)
        .background(SbuTheme.surface, in: .rect(cornerRadius: SbuTheme.radiusLg))
        .padding(SbuTheme.space4)
    }

    private func toggleLock() {
        isLocked.toggle()
    }
}

#Preview("Light") {
    @Previewable @State var opacity = 0.5
    @Previewable @State var isLocked = false
    TraceControls(opacity: $opacity, isLocked: $isLocked)
        .background(SbuTheme.inkMuted)
}

#Preview("Dark") {
    @Previewable @State var opacity = 0.5
    @Previewable @State var isLocked = true
    TraceControls(opacity: $opacity, isLocked: $isLocked)
        .background(SbuTheme.inkMuted)
        .preferredColorScheme(.dark)
}
