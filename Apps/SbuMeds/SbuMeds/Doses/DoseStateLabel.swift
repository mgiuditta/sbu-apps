import SbuKit
import SwiftUI

/// Where a dose stands, always in words, after the row marker: filled once the dose is taken.
struct DoseStateLabel: View {
    let item: DoseItem

    var body: some View {
        HStack(spacing: SbuTheme.space2) {
            SbuRowMark(filled: item.state.isTaken)
            text
        }
        .font(SbuTheme.footnote)
        .foregroundStyle(item.state.isTaken || item.state == .late ? SbuTheme.ink : SbuTheme.inkMuted)
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
}

#Preview("Light") {
    DoseRowsPreview()
}

#Preview("Dark") {
    DoseRowsPreview()
        .preferredColorScheme(.dark)
}
