import SbuKit
import SwiftUI

/// The tool screen's pills: Azzera qui or Assoluto, Blocca or Sblocca, and Mirino, laid out by the container.
struct LevelPills: View {
    let isRelative: Bool
    let isLocked: Bool
    let isWaitingForSteady: Bool
    let isSighting: Bool
    let toggleReference: () -> Void
    let toggleLock: () -> Void
    let toggleSight: () -> Void

    var body: some View {
        Button(isRelative ? "Assoluto" : "Azzera qui", systemImage: "angle", action: toggleReference)
            .buttonStyle(SbuFieldPillStyle(isSelected: isRelative))
            .sbuAffectsFigure(isRelative)

        LockPill(isLocked: isLocked, isWaitingForSteady: isWaitingForSteady, action: toggleLock)

        Button("Mirino", systemImage: "camera.viewfinder", action: toggleSight)
            .buttonStyle(SbuFieldPillStyle(isSelected: isSighting))
    }
}

#Preview("Light") {
    HStack(spacing: SbuTheme.space2) {
        LevelPills(isRelative: false, isLocked: false, isWaitingForSteady: false, isSighting: false, toggleReference: {}, toggleLock: {}, toggleSight: {})
    }
    .padding(SbuTheme.space4)
    .background(SbuTheme.paper)
}

#Preview("Dark") {
    HStack(spacing: SbuTheme.space2) {
        LevelPills(isRelative: true, isLocked: false, isWaitingForSteady: true, isSighting: true, toggleReference: {}, toggleLock: {}, toggleSight: {})
    }
    .padding(SbuTheme.space4)
    .background(SbuTheme.paper)
    .preferredColorScheme(.dark)
}
