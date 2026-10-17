import SbuKit
import SwiftUI

/// The one figure of a management screen: a space in MB or GB, closed by the full stop, with what
/// it counts in the line under it ("Nel cestino · 37 elementi").
///
/// The stop sets when there is space to show and waits at zero, or while `isCounting`. VoiceOver
/// reads the label first, as the screen's tests find it: "Nel cestino, 1,26 GB, 37 elementi".
struct SpaceStat: View {
    let label: LocalizedStringKey
    let bytes: Int64
    var context: LocalizedStringKey?
    var isCounting = false

    var body: some View {
        let figure = SpaceFigure(bytes: bytes)
        SbuFigure(
            value: figure.number,
            unit: figure.figureUnit,
            fullStop: bytes > 0 && !isCounting ? .set : .waiting,
            context: contextLine,
            accessibilityLabel: spoken
        )
        .frame(maxWidth: .infinity, alignment: .leading)
        // Its own paper, so the baseline snaps once, not again on every scroll of the list around it.
        .sbuPaper(grid: false)
    }

    private var contextLine: Text {
        guard let context else { return Text(label) }
        return Text("\(Text(label)) · \(Text(context))")
    }

    private var spoken: Text {
        let size = bytes.sizeText
        guard let context else { return Text("\(Text(label)), \(size)") }
        return Text("\(Text(label)), \(size), \(Text(context))")
    }
}

#Preview("Light") {
    SpaceStat(label: "Nel cestino", bytes: 1_260_000_000, context: "37 elementi")
        .padding()
        .environment(\.sbuAccent, .clean)
}

#Preview("Dark") {
    SpaceStat(label: "Nel cestino", bytes: 0, context: "12 elementi")
        .padding()
        .environment(\.sbuAccent, .clean)
        .preferredColorScheme(.dark)
}
