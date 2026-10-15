import SbuKit
import SwiftUI

/// Why a form cannot be saved, or something worth a second look: always a word and a symbol.
struct ProblemLabel: View {
    let text: Text
    var tone = SbuStatusTone.danger

    var body: some View {
        Label {
            text
        } icon: {
            Image(systemName: "exclamationmark.triangle")
                .fontWeight(.medium)
        }
        .font(SbuTheme.footnote)
        .foregroundStyle(tone == .danger ? SbuTheme.danger : SbuTheme.warning)
        .accessibilityIdentifier("problem")
    }
}

#Preview("Light") {
    Form {
        Section {
        } footer: {
            ProblemLabel(text: Text(verbatim: "Il 12 mar 2026 il contachilometri segnava già 45.210 km."))
        }
    }
}

#Preview("Dark") {
    Form {
        Section {
        } footer: {
            ProblemLabel(text: Text(verbatim: "Più del serbatoio."), tone: .warning)
        }
    }
    .preferredColorScheme(.dark)
}
