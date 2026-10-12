import SbuKit
import SwiftUI

/// A habit's symbol inside a ring that fills in the accent, one segment per time of the day;
/// over the Limite of an Abitudine da evitare, in `danger`, with the cross.
struct HabitRing: View {
    /// Space between segments, as a fraction of the whole ring.
    private static let gap = 0.02

    let symbol: String
    /// How many segments: the habit's times per day.
    let segments: Int
    /// How many segments are filled; the fraction of the last one animates while holding.
    let filled: Double
    /// Draws the fill in `danger`: only ever with the cross, never color alone.
    let isOverLimit: Bool

    init(symbol: String, segments: Int, filled: Double, isOverLimit: Bool = false) {
        self.symbol = symbol
        self.segments = segments
        self.filled = filled
        self.isOverLimit = isOverLimit
    }

    init(face: HabitRingFace, isHolding: Bool = false) {
        self.init(symbol: face.symbol, segments: face.segments, filled: face.filled(isHolding: isHolding), isOverLimit: face.isOverLimit)
    }

    private var lineCap: CGLineCap {
        segments > 1 ? .butt : .round
    }

    var body: some View {
        ZStack {
            ForEach(0..<segments, id: \.self) { index in
                let range = segmentRange(index)
                let fill = min(max(filled - Double(index), 0), 1)

                Circle()
                    .trim(from: range.lowerBound, to: range.upperBound)
                    .stroke(SbuTheme.line, style: StrokeStyle(lineWidth: SbuTheme.space2, lineCap: lineCap))

                Circle()
                    .trim(from: range.lowerBound, to: range.lowerBound + (range.upperBound - range.lowerBound) * fill)
                    .stroke(.tint, style: StrokeStyle(lineWidth: SbuTheme.space2, lineCap: lineCap))
            }
            .rotationEffect(.degrees(-90))
            .tint(isOverLimit ? SbuTheme.danger : nil)

            Image(systemName: symbol)
                .font(SbuTheme.title2)
                .fontWeight(.medium)
                .imageScale(.medium)
                .foregroundStyle(SbuTheme.ink)
        }
        .padding(SbuTheme.space1)
        .accessibilityHidden(true)
    }

    /// The part of the ring a segment covers; a single segment is the whole ring, without a gap.
    private func segmentRange(_ index: Int) -> ClosedRange<Double> {
        guard segments > 1 else { return 0...1 }
        let size = 1 / Double(segments)
        return (Double(index) * size + Self.gap / 2)...(Double(index + 1) * size - Self.gap / 2)
    }
}

#Preview("Light") {
    HabitRingPreview()
}

#Preview("Dark") {
    HabitRingPreview()
        .preferredColorScheme(.dark)
}

private struct HabitRingPreview: View {
    var body: some View {
        HStack(spacing: SbuTheme.space4) {
            HabitRing(symbol: "book", segments: 1, filled: 0)
            HabitRing(symbol: "checkmark", segments: 1, filled: 1)
            HabitRing(symbol: "drop", segments: 8, filled: 3.5)
            HabitRing(symbol: "xmark", segments: 2, filled: 2, isOverLimit: true)
        }
        .frame(height: SbuTheme.space12 * 2)
        .padding(SbuTheme.space4)
        .background(SbuTheme.surface)
        .tint(SbuTheme.accentHabits)
    }
}
