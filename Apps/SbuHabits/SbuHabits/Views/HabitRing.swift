import SbuKit
import SwiftUI

/// A habit's symbol inside a ring that fills in the accent as it gets done.
struct HabitRing: View {
    let symbol: String
    /// From 0 (to do) to 1 (done).
    let progress: Double

    var body: some View {
        ZStack {
            Circle()
                .stroke(SbuTheme.fieldControlActive, lineWidth: SbuTheme.space1)

            Circle()
                .trim(from: 0, to: progress)
                .stroke(.tint, style: StrokeStyle(lineWidth: SbuTheme.space1, lineCap: .round))
                .rotationEffect(.degrees(-90))

            Image(systemName: symbol)
                .font(.title3)
                .fontWeight(.medium)
                .imageScale(.medium)
                .foregroundStyle(SbuTheme.onField)
        }
        .padding(SbuTheme.space1 / 2)
        .accessibilityHidden(true)
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
            HabitRing(symbol: "drop", progress: 0)
            HabitRing(symbol: "book", progress: 1)
        }
        .frame(height: SbuTheme.space12)
        .padding(SbuTheme.space4)
        .background(SbuTheme.fieldHabits)
        .tint(SbuTheme.accentHabits)
    }
}
