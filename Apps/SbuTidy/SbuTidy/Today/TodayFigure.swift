import SbuKit
import SwiftUI

/// The figure of the app: chores to do today, late ones included, closed by the full stop.
struct TodayFigure: View {
    let toDoCount: Int
    let overdueCount: Int

    var body: some View {
        SbuStat("Da fare oggi", value: toDoCount, format: .number, context: context)
            .accessibilityIdentifier("todayFigure")
    }

    private var context: LocalizedStringKey {
        if overdueCount > 0 { return "di cui \(overdueCount) in ritardo" }
        return toDoCount == 0 ? "Casa in ordine" : "Niente in ritardo"
    }
}

#Preview("Light") {
    TodayFigurePreview()
}

#Preview("Dark") {
    TodayFigurePreview()
        .preferredColorScheme(.dark)
}

private struct TodayFigurePreview: View {
    var body: some View {
        VStack(spacing: SbuTheme.space4) {
            TodayFigure(toDoCount: 7, overdueCount: 3)
            TodayFigure(toDoCount: 0, overdueCount: 0)
        }
        .padding(SbuTheme.space4)
        .frame(maxHeight: .infinity)
        .background(SbuTheme.surface)
        .tint(SbuTheme.accentTidy)
    }
}
