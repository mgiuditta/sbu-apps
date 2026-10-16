import SbuKit
import SwiftUI

/// What the maximum size does, and whether it fits the picked videos.
struct TargetFooter: View {
    let hasTarget: Bool
    let targetFit: TargetFit?

    var body: some View {
        if !hasTarget {
            Text("Ogni video viene compresso per pesare al massimo questi MB, e la qualità si regola da sola.")
        } else {
            switch targetFit {
            case .tooSmall:
                Label("Per alcuni video non basta: verranno più pesanti. Riduci le dimensioni o togli l'audio.", systemImage: "exclamationmark.triangle")
                    .foregroundStyle(SbuTheme.warning)
            case .alreadySmaller:
                Text("I video ci stanno già alla qualità piena: verranno più leggeri del limite.")
            case .fits, nil:
                Text("Ogni video viene compresso per pesare al massimo questi MB.")
            }
        }
    }
}

#Preview("Light") {
    List {
        Section {} footer: {
            TargetFooter(hasTarget: true, targetFit: .tooSmall)
        }
    }
}

#Preview("Dark") {
    List {
        Section {} footer: {
            TargetFooter(hasTarget: false, targetFit: nil)
        }
    }
    .preferredColorScheme(.dark)
}
