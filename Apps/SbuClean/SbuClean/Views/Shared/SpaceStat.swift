import SbuKit
import SwiftUI

/// The one figure of a management screen: a space in MB or GB, closed by the full stop.
struct SpaceStat: View {
    let label: LocalizedStringKey
    let bytes: Int64
    var context: LocalizedStringKey?

    var body: some View {
        let figure = SpaceFigure(bytes: bytes)
        SbuStat(label, value: figure.number, format: figure.format, unit: figure.unit, context: context)
    }
}

#Preview("Light") {
    SpaceStat(label: "Nel cestino", bytes: 1_260_000_000, context: "37 elementi")
        .padding()
        .tint(SbuTheme.accentClean)
}

#Preview("Dark") {
    SpaceStat(label: "Nel cestino", bytes: 340_000_000, context: "12 elementi")
        .padding()
        .tint(SbuTheme.accentClean)
        .preferredColorScheme(.dark)
}
