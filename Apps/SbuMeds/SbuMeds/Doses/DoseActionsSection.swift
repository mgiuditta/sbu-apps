import SbuKit
import SwiftUI

/// Presa, Saltata, Sposta orario; and for a marked dose, back to "da prendere".
struct DoseActionsSection: View {
    let item: DoseItem
    @Binding var isMoving: Bool
    @Binding var moveTo: Date
    let mark: (DoseMark) -> Void
    let unmark: () -> Void
    let move: () -> Void

    var body: some View {
        Section {
            VStack(spacing: SbuTheme.space3) {
                if !item.state.isTaken {
                    SbuButton("Presa") { mark(.taken) }
                        .accessibilityIdentifier("markTaken")
                }
                if item.state != .skipped {
                    SbuButton("Saltata", kind: .secondary) { mark(.skipped) }
                        .accessibilityIdentifier("markSkipped")
                }
                if item.state.isToTake {
                    SbuButton("Sposta orario", kind: .secondary) { isMoving.toggle() }
                        .accessibilityIdentifier("moveDose")
                }
                if !item.state.isToTake, item.state != .missed {
                    SbuButton("Segna da prendere", kind: .secondary, action: unmark)
                        .accessibilityIdentifier("unmark")
                }
            }
        }
        .listRowInsets(EdgeInsets())
        .listRowBackground(Color.clear)
        if isMoving {
            Section {
                DatePicker("Nuovo orario", selection: $moveTo, displayedComponents: .hourAndMinute)
                Button("Sposta", action: move)
                    .accessibilityIdentifier("confirmMove")
            } footer: {
                Text("Il promemoria si sposta con la dose.")
            }
            .listRowBackground(SbuTheme.surfaceRaised)
        }
    }
}

#Preview("Light") {
    DoseActionsSectionPreview()
}

#Preview("Dark") {
    DoseActionsSectionPreview()
        .preferredColorScheme(.dark)
}

private struct DoseActionsSectionPreview: View {
    @State private var isMoving = true
    @State private var moveTo = Date.now

    var body: some View {
        let today = Day(.now, calendar: .current)
        let medicine = MedicineSnapshot(name: "Ramipril", schedule: Schedule(times: [DoseTime(hour: 23, minute: 59)], start: today))
        List {
            if let item = DayPlan([medicine], day: today, now: .now, calendar: .current).items.first {
                DoseActionsSection(item: item, isMoving: $isMoving, moveTo: $moveTo, mark: { _ in }, unmark: {}, move: {})
            }
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
        .background(SbuTheme.surface)
        .tint(SbuTheme.accentMeds)
    }
}
