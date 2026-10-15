import SbuKit
import SwiftUI

/// The tool screen's pills: Azzera qui or Assoluto, and Blocca or Sblocca, laid out by the container.
struct LevelPills: View {
    let isRelative: Bool
    let isLocked: Bool
    let toggleReference: () -> Void
    let toggleLock: () -> Void

    var body: some View {
        Button(isRelative ? "Assoluto" : "Azzera qui", systemImage: "angle", action: toggleReference)
            .buttonStyle(SbuFieldPillStyle(isSelected: isRelative))

        Button(isLocked ? "Sblocca" : "Blocca", systemImage: isLocked ? "lock.fill" : "lock.open", action: toggleLock)
            .buttonStyle(SbuFieldPillStyle(isSelected: isLocked))
    }
}

#Preview("Light") {
    HStack(spacing: SbuTheme.space2) {
        LevelPills(isRelative: false, isLocked: false, toggleReference: {}, toggleLock: {})
    }
    .padding(SbuTheme.space4)
    .background(SbuTheme.surface)
}

#Preview("Dark") {
    HStack(spacing: SbuTheme.space2) {
        LevelPills(isRelative: true, isLocked: true, toggleReference: {}, toggleLock: {})
    }
    .padding(SbuTheme.space4)
    .background(SbuTheme.surface)
    .preferredColorScheme(.dark)
}
