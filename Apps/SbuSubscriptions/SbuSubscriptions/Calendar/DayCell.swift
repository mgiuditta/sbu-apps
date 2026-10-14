import SbuKit
import SwiftUI

/// One day of the month: its number, a dot when something is paid, today in the accent.
struct DayCell: View {
    let day: Date
    let payments: [MonthPayments.Payment]
    let isToday: Bool
    let isSelected: Bool
    let select: () -> Void
    let addFromHere: () -> Void

    var body: some View {
        Button(action: select) {
            VStack(spacing: SbuTheme.space1) {
                Text(day, format: .dateTime.day())
                    .font(isToday ? SbuTheme.headline : SbuTheme.body)
                    .foregroundStyle(isToday ? AnyShapeStyle(.tint) : AnyShapeStyle(SbuTheme.ink))
                Image(systemName: "circle.fill")
                    .font(SbuTheme.caption)
                    .imageScale(.small)
                    .foregroundStyle(SbuTheme.ink)
                    .opacity(payments.isEmpty ? 0 : 1)
            }
            .frame(maxWidth: .infinity, minHeight: 44)
            .padding(.vertical, SbuTheme.space1)
            .background(isSelected ? SbuTheme.surfaceSunken : .clear, in: .rect(cornerRadius: SbuTheme.radiusMd))
            .contentShape(.rect)
        }
        .buttonStyle(.plain)
        .contextMenu {
            Button("Aggiungi da questo giorno", systemImage: "plus", action: addFromHere)
        }
        .accessibilityLabel(label)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
        .accessibilityAction(named: "Aggiungi da questo giorno", addFromHere)
    }

    private var label: Text {
        let date = day.formatted(.dateTime.day().month(.wide))
        let names = payments.map(\.subscription.name).formatted(.list(type: .and))
        switch (isToday, payments.isEmpty) {
        case (true, true): return Text("Oggi, \(date)")
        case (true, false): return Text("Oggi, \(date): \(names)")
        case (false, true): return Text(date)
        case (false, false): return Text("\(date): \(names)")
        }
    }
}
