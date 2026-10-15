import SbuKit
import SwiftUI

/// The lock pill: Blocca, In attesa while the steady lock waits for the reading to hold still,
/// and Sblocca once frozen. Selected in both of the last two, which a tap undoes.
struct LockPill: View {
    let isLocked: Bool
    let isWaitingForSteady: Bool
    let action: () -> Void

    private var title: LocalizedStringKey {
        if isLocked {
            "Sblocca"
        } else if isWaitingForSteady {
            "In attesa"
        } else {
            "Blocca"
        }
    }

    private var systemImage: String {
        if isLocked {
            "lock.fill"
        } else if isWaitingForSteady {
            "hourglass"
        } else {
            "lock.open"
        }
    }

    var body: some View {
        Button(title, systemImage: systemImage, action: action)
            .buttonStyle(SbuFieldPillStyle(isSelected: isLocked || isWaitingForSteady))
    }
}

#Preview("Light") {
    VStack(spacing: SbuTheme.space2) {
        LockPill(isLocked: false, isWaitingForSteady: false) {}
        LockPill(isLocked: false, isWaitingForSteady: true) {}
    }
    .padding(SbuTheme.space4)
    .background(SbuTheme.surface)
}

#Preview("Dark") {
    LockPill(isLocked: true, isWaitingForSteady: false) {}
        .padding(SbuTheme.space4)
        .background(SbuTheme.surface)
        .preferredColorScheme(.dark)
}
