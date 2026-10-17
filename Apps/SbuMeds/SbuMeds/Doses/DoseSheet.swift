import SbuKit
import SwiftData
import SwiftUI

/// Medisafe's dose card: the medicine, how much, when, and Presa, Saltata, Sposta orario.
/// A marked dose can be unmarked; an extra dose can be removed.
struct DoseSheet: View {
    let item: DoseItem
    let medicine: Medicine

    @Environment(\.modelContext) private var modelContext
    @Environment(\.calendar) private var calendar
    @Environment(\.dismiss) private var dismiss
    @Environment(Clock.self) private var clock
    @State private var isMoving = false
    @State private var moveTo = Date.now

    private var canMark: Bool { item.key.day <= Day(clock.now, calendar: calendar) }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    DoseSheetHeader(item: item)
                }
                .listRowBackground(SbuTheme.surfaceRaised)
                if item.isExtra {
                    Section {
                        SbuButton("Elimina dose extra", kind: .destructive, confirmationTitle: "Eliminare questa dose extra?", action: deleteExtra)
                            .accessibilityIdentifier("deleteExtra")
                    }
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
                } else if canMark {
                    DoseActionsSection(item: item, isMoving: $isMoving, moveTo: $moveTo, mark: mark, unmark: unmark, move: move)
                } else {
                    Section {
                    } footer: {
                        Text("Puoi segnarla dal giorno in cui è prevista.")
                    }
                }
            }
            .listStyle(.insetGrouped)
            .scrollContentBackground(.hidden)
            .background(SbuTheme.paper)
            .navigationTitle(medicine.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Chiudi", action: close)
                        .accessibilityIdentifier("closeDose")
                }
            }
        }
        .presentationDetents([.medium, .large])
        .onAppear {
            moveTo = max(item.dueDate, clock.now).addingTimeInterval(30 * 60)
        }
    }

    private func mark(_ mark: DoseMark) {
        Cabinet.mark(item.key, of: medicine, as: mark, amount: item.amount, at: clock.now, in: modelContext)
        finish()
    }

    private func unmark() {
        Cabinet.unmark(item.key, of: medicine, in: modelContext)
        finish()
    }

    private func move() {
        // The time picked, on the dose's own day.
        let parts = calendar.dateComponents([.hour, .minute], from: moveTo)
        let date = item.key.day.date(atMinutes: (parts.hour ?? 0) * 60 + (parts.minute ?? 0), in: calendar)
        Cabinet.move(item.key, of: medicine, to: date, amount: item.amount, in: modelContext)
        finish()
    }

    private func deleteExtra() {
        if let record = medicine.recordList.first(where: { $0.isExtra && $0.dayKey == item.key.day.key && $0.minutes == item.key.minutes }) {
            Cabinet.delete(record, in: modelContext)
        }
        finish()
    }

    private func finish() {
        try? modelContext.save()
        clock.refresh()
        dismiss()
    }

    private func close() {
        dismiss()
    }
}

#Preview("Light") {
    DoseSheetPreview()
}

#Preview("Dark") {
    DoseSheetPreview()
        .preferredColorScheme(.dark)
}

private struct DoseSheetPreview: View {
    @Query private var medicines: [Medicine]

    var body: some View {
        Group {
            if let medicine = medicines.first(where: { $0.schedule.frequency == .daily }),
               let item = DayPlan([medicine.snapshot], day: Day(.now, calendar: .current), now: .now, calendar: .current).items.first {
                DoseSheet(item: item, medicine: medicine)
            }
        }
        .modelContainer(.preview)
        .environment(Clock())
        .environment(\.sbuAccent, .meds)
    }
}
