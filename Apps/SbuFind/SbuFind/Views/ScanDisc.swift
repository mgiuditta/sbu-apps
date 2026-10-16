import SbuKit
import SwiftUI

/// Three discs in the accent around the antenna symbol, the outer two breathing in and out
/// like a radar sweep. Still with Reduce Motion. Decorative: the card's title says it all.
struct ScanDisc: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var isBreathing = false

    var body: some View {
        GeometryReader { proxy in
            let side = min(proxy.size.width, proxy.size.height)
            ZStack {
                Circle()
                    .fill(.tint.opacity(0.15))
                    .frame(width: side, height: side)
                    .scaleEffect(isBreathing ? 1 : 0.86)

                Circle()
                    .fill(.tint.opacity(0.3))
                    .frame(width: side * 0.72, height: side * 0.72)
                    .scaleEffect(isBreathing ? 1.04 : 0.94)

                Circle()
                    .fill(.tint)
                    .frame(width: side * 0.44, height: side * 0.44)

                Image(systemName: "antenna.radiowaves.left.and.right")
                    .resizable()
                    .scaledToFit()
                    .fontWeight(.medium)
                    .foregroundStyle(SbuTheme.onAccent)
                    .frame(width: side * 0.2, height: side * 0.2)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .accessibilityHidden(true)
        .onAppear(perform: startBreathing)
    }

    private func startBreathing() {
        guard Breathing.isAllowed(reduceMotion: reduceMotion) else { return }
        withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
            isBreathing = true
        }
    }
}

#Preview("Light") {
    ScanDisc()
        .frame(height: 160)
        .tint(SbuTheme.accentFind)
}

#Preview("Dark") {
    ScanDisc()
        .frame(height: 160)
        .tint(SbuTheme.accentFind)
        .preferredColorScheme(.dark)
}
