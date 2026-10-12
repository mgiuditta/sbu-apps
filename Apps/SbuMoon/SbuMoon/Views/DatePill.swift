import SbuKit
import SwiftUI

/// The pill with the date shown, "Oggi" or the picked day, which opens the calendar.
struct DatePill: View {
    let date: Date
    let isToday: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Label {
                if isToday {
                    Text("Oggi")
                } else {
                    Text(date, format: .dateTime.day().month(.abbreviated).year())
                }
            } icon: {
                Image(systemName: "calendar")
                    .fontWeight(.medium)
                    .imageScale(.medium)
            }
        }
        .buttonStyle(SbuFieldPillStyle())
        .accessibilityHint("Scegli un altro giorno")
        .accessibilityIdentifier("date")
    }
}

#Preview("Light") {
    DatePillPreview()
}

#Preview("Dark") {
    DatePillPreview()
        .preferredColorScheme(.dark)
}

private struct DatePillPreview: View {
    var body: some View {
        VStack(spacing: SbuTheme.space4) {
            DatePill(date: .now, isToday: true) {}
            DatePill(date: .now.addingTimeInterval(86_400 * 40), isToday: false) {}
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(SbuTheme.surface)
    }
}
