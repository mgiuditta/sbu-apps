import SbuKit
import SwiftUI

/// Where a dose stands, always in words with a symbol, colored only as a second cue.
struct DoseStateLabel: View {
    let item: DoseItem

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: SbuTheme.space1) {
            Image(systemName: symbol)
                .fontWeight(.medium)
                .imageScale(.medium)
                .accessibilityHidden(true)
            text
        }
        .font(SbuTheme.footnote)
        .foregroundStyle(color)
    }

    private var text: Text {
        let time = Text(item.dueDate, format: .dateTime.hour().minute())
        switch item.state {
        case .taken(let date): return Text("Presa alle \(Text(date, format: .dateTime.hour().minute()))")
        case .skipped: return Text("Saltata")
        case .missed: return Text("Non segnata")
        case .late: return item.isMoved ? Text("In ritardo, spostata alle \(time)") : Text("In ritardo")
        case .upcoming: return item.isMoved ? Text("Spostata alle \(time)") : Text("Da prendere")
        }
    }

    private var symbol: String {
        switch item.state {
        case .taken: "checkmark.circle.fill"
        case .skipped: "minus.circle"
        case .missed: "exclamationmark.circle"
        case .late: "clock"
        case .upcoming: item.isMoved ? "clock.arrow.circlepath" : "circle"
        }
    }

    private var color: Color {
        switch item.state {
        case .taken: SbuTheme.success
        case .missed: SbuTheme.danger
        case .late: SbuTheme.warning
        case .skipped, .upcoming: SbuTheme.inkMuted
        }
    }
}

#Preview("Light") {
    DoseRowsPreview()
}

#Preview("Dark") {
    DoseRowsPreview()
        .preferredColorScheme(.dark)
}
