import SbuKit
import SwiftData
import SwiftUI

/// The tool screen, Medisafe's home: the person on top, the week, how many doses are still to
/// take that day, closed by the full stop, then the doses grouped by time. Always opens on today.
struct TodayView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.calendar) private var calendar
    @Environment(Clock.self) private var clock
    @Query(sort: [SortDescriptor(\Person.order), SortDescriptor(\Person.createdAt)]) private var people: [Person]
    @Query private var medicines: [Medicine]
    @AppStorage("today.person") private var personID = ""
    @State private var selectedDay: Day?
    @State private var openDose: DoseItem?
    @State private var newMedicineFor: Person?
    @State private var markCount = 0

    var body: some View {
        let person = people.first { $0.id.uuidString == personID } ?? people.first
        let today = Day(clock.now, calendar: calendar)
        let day = selectedDay ?? today
        let mine = medicines.filter { $0.person?.id == person?.id }
        let snapshots = mine.map(\.snapshot)
        let plan = DayPlan(snapshots, day: day, now: clock.now, calendar: calendar)
        let byID = Dictionary(mine.map { ($0.id, $0) }, uniquingKeysWith: { first, _ in first })
        let asNeeded = mine.filter { $0.schedule.frequency == .asNeeded }.sorted { $0.name < $1.name }
        List {
            Section {
                PersonPicker(people: people, selection: personSelection(current: person))
                WeekStrip(selection: daySelection(today: today), today: today)
            }
            .listRowInsets(EdgeInsets())
            .listRowBackground(Color.clear)
            .listRowSeparator(.hidden)
            Section {
                TodayFigure(plan: plan, isToday: day == today)
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
            }
            if plan.isEmpty, asNeeded.isEmpty || day != today {
                TodayEmptyRow(hasMedicines: !mine.isEmpty, isToday: day == today, addMedicine: { newMedicineFor = person })
            }
            ForEach(plan.groups) { group in
                DoseGroupSection(group: group, canMark: day <= today, open: open, takeAll: takeAll, mark: { mark($0, as: $1, in: byID) })
            }
            if day == today, !asNeeded.isEmpty {
                AsNeededSection(medicines: asNeeded, take: takeAsNeeded)
            }
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                NavigationLink(value: Destination.medicines) {
                    Label("Farmaci", systemImage: "pills")
                }
                .tint(SbuTheme.ink)
                .accessibilityIdentifier("medicines")
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button("Aggiungi farmaco", systemImage: "plus") { newMedicineFor = person }
                    .tint(SbuTheme.ink)
                    .accessibilityIdentifier("addMedicine")
            }
        }
        .navigationDestination(for: Destination.self) { destination in
            switch destination {
            case .medicines: MedicinesView()
            case .report: ReportView()
            }
        }
        .navigationDestination(for: Medicine.self) { medicine in
            MedicineView(medicine: medicine)
        }
        .sheet(item: $openDose) { item in
            if let medicine = byID[item.key.medicineID] {
                DoseSheet(item: item, medicine: medicine)
            }
        }
        .sheet(item: $newMedicineFor) { person in
            MedicineEditor(person: person, medicine: nil)
        }
        .sensoryFeedback(.success, trigger: markCount)
    }

    private func personSelection(current: Person?) -> Binding<UUID?> {
        Binding { current?.id } set: { personID = $0?.uuidString ?? "" }
    }

    private func daySelection(today: Day) -> Binding<Day> {
        Binding { selectedDay ?? today } set: { selectedDay = $0 == today ? nil : $0 }
    }

    private func open(_ item: DoseItem) {
        openDose = item
    }

    private func mark(_ item: DoseItem, as mark: DoseMark, in medicines: [UUID: Medicine]) {
        guard let medicine = medicines[item.key.medicineID] else { return }
        Cabinet.mark(item.key, of: medicine, as: mark, amount: item.amount, at: clock.now, in: modelContext)
        save()
    }

    /// "Prendi tutto": every dose of the time still to take, early ones too.
    private func takeAll(_ group: DayPlan.Group) {
        let byID = Dictionary(medicines.map { ($0.id, $0) }, uniquingKeysWith: { first, _ in first })
        for item in group.toTake {
            mark(item, as: .taken, in: byID)
        }
    }

    private func takeAsNeeded(_ medicine: Medicine) {
        Cabinet.takeExtra(medicine, amount: medicine.asNeededAmount, at: clock.now, calendar: calendar, in: modelContext)
        save()
    }

    private func save() {
        try? modelContext.save()
        clock.refresh()
        markCount += 1
    }
}

#Preview("Light") {
    NavigationStack {
        TodayView()
    }
    .modelContainer(.preview)
    .environment(Clock())
    .tint(SbuTheme.accentMeds)
}

#Preview("Dark") {
    NavigationStack {
        TodayView()
    }
    .modelContainer(.preview)
    .environment(Clock())
    .tint(SbuTheme.accentMeds)
    .preferredColorScheme(.dark)
}
