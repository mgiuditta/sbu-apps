import SbuKit
import SwiftUI

/// The tool screen's pills: Calibra, and Blocca or Sblocca, laid out by the container.
struct LevelPills: View {
    let isLocked: Bool
    let calibrate: () -> Void
    let toggleLock: () -> Void

    var body: some View {
        Button("Calibra", action: calibrate)
            .buttonStyle(SbuFieldPillStyle())

        Button(isLocked ? "Sblocca" : "Blocca", systemImage: isLocked ? "lock.fill" : "lock.open", action: toggleLock)
            .buttonStyle(SbuFieldPillStyle(isSelected: isLocked))
    }
}

#Preview("Light") {
    HStack(spacing: SbuTheme.space2) {
        LevelPills(isLocked: false, calibrate: {}, toggleLock: {})
    }
    .padding(SbuTheme.space4)
    .background(SbuTheme.surface)
}

#Preview("Dark") {
    HStack(spacing: SbuTheme.space2) {
        LevelPills(isLocked: true, calibrate: {}, toggleLock: {})
    }
    .padding(SbuTheme.space4)
    .background(SbuTheme.surface)
    .preferredColorScheme(.dark)
}
