import SbuKit
import SwiftData
import SwiftUI

/// The tool screen, Medisafe's home: the title and how many doses are still to take that day on
/// the paper's grid, closed by the full stop, then the person, the week and the doses grouped by
/// time. Always opens on today; the last dose of today taken plays the Closure "Presa".
struct TodayView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.calendar) private var calendar
    @Environment(Clock.self) private var clock
    @Environment(Reminders.self) private var reminders
    @Query(sort: [SortDescriptor(\Person.order), SortDescriptor(\Person.createdAt)]) private var people: [Person]
    @Query private var medicines: [Medicine]
    @AppStorage("today.person") private var personID = ""
    @State private var selectedDay: Day?
    @State private var openDose: DoseItem?
    @State private var newMedicineFor: Person?
    @State private var markCount = 0
    @State private var isClosing = false

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
                TodayFigure(plan: plan, isToday: day == today, hasMedicines: !mine.isEmpty, isClosing: $isClosing) {
                    newMedicineFor = person
                }
                // On the row's content, not the list: the grid scrolls with the figure.
                .sbuPaper(grid: true)
                .listRowInsets(EdgeInsets())
                .listRowBackground(Color.clear)
            }
            if people.count > 1 || !mine.isEmpty {
                Section {
                    if people.count > 1 {
                        PersonPicker(people: people, selection: personSelection(current: person))
                    }
                    if !mine.isEmpty {
                        WeekStrip(selection: daySelection(today: today), today: today)
                            .sbuAffectsFigure(day)
                    }
                }
                .listRowInsets(EdgeInsets())
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
            }
            if let days = reminders.openEveryDays {
                Section {
                    OpenAppNotice(days: days)
                }
                .listRowBackground(SbuTheme.surfaceRaised)
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
                .accessibilityIdentifier("medicines")
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button("Aggiungi farmaco", systemImage: "plus") { newMedicineFor = person }
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
        .sbuAffectsFigure(markCount)
        // The last dose of today taken, from a row, "Prendi tutto" or the dose's card: the Closure.
        .onChange(of: day == today ? TodayProgress(personID: person?.id, plan: plan) : nil) { previous, current in
            if let previous, let current, current.closes(after: previous) {
                isClosing = true
            }
        }
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
    .environment(Reminders(center: SilentReminderCenter()))
    .environment(\.sbuAccent, .meds)
}

#Preview("Dark") {
    NavigationStack {
        TodayView()
    }
    .modelContainer(.preview)
    .environment(Clock())
    .environment(Reminders(center: SilentReminderCenter()))
    .environment(\.sbuAccent, .meds)
    .preferredColorScheme(.dark)
}
