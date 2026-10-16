import SbuKit
import SwiftData
import SwiftUI

/// Medisafe's report, free: whose, which period and which medicines, the share of doses taken as
/// the figure, then the PDF for the doctor, made on the iPhone and shared from here.
struct ReportView: View {
    @Environment(\.calendar) private var calendar
    @Environment(Clock.self) private var clock
    @Query(sort: [SortDescriptor(\Person.order), SortDescriptor(\Person.createdAt)]) private var people: [Person]
    @State private var personID: UUID?
    @State private var period = ReportPeriod.month
    @State private var customFirst = Date.now.addingTimeInterval(-13 * 86_400)
    @State private var customLast = Date.now
    @State private var excluded: Set<UUID> = []
    @State private var file: URL?

    var body: some View {
        let person = people.first { $0.id == personID } ?? people.first
        let today = Day(clock.now, calendar: calendar)
        let range = period.range(today: today, customFirst: Day(customFirst, calendar: calendar), customLast: Day(customLast, calendar: calendar), calendar: calendar)
        let medicines = (person?.medicineList ?? []).filter { $0.schedule.frequency != .asNeeded || !$0.recordList.isEmpty }
        let report = Report(
            personName: person?.name ?? "", medicines: medicines.filter { !excluded.contains($0.id) }.map(\.snapshot),
            from: range.first, through: range.last, now: clock.now, calendar: calendar
        )
        List {
            Section {
                ReportFigure(adherence: report.adherence)
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
            }
            Section {
                Picker("Persona", selection: personSelection(current: person)) {
                    ForEach(people) { Text($0.name).tag(Optional($0.id)) }
                }
                Picker("Periodo", selection: $period) {
                    ForEach(ReportPeriod.allCases) { Text($0.name).tag($0) }
                }
                .accessibilityIdentifier("period")
                if period == .custom {
                    DatePicker("Dal", selection: $customFirst, in: ...clock.now, displayedComponents: .date)
                    DatePicker("Al", selection: $customLast, in: ...clock.now, displayedComponents: .date)
                }
            }
            .listRowBackground(SbuTheme.surfaceRaised)
            if !medicines.isEmpty {
                Section {
                    ForEach(medicines) { medicine in
                        Toggle(isOn: inclusion(of: medicine.id)) {
                            Text(medicine.strength.isEmpty ? medicine.name : "\(medicine.name) · \(medicine.strength)")
                        }
                    }
                } header: {
                    Text("Farmaci")
                } footer: {
                    Text("Nel PDF: le dosi di ogni giorno con l'orario, prese, saltate o non segnate.")
                }
                .listRowBackground(SbuTheme.surfaceRaised)
            }
            Section {
                if let file {
                    ShareLink(item: file, preview: SharePreview(report.fileName)) {
                        Label("Condividi PDF", systemImage: "square.and.arrow.up")
                    }
                    .accessibilityIdentifier("sharePDF")
                } else {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                }
            } footer: {
                Text("Fatto sull'iPhone, non passa da nessun server. Lo mandi tu, a chi vuoi.")
            }
            .listRowBackground(SbuTheme.surfaceRaised)
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
        .background(SbuTheme.surface)
        .navigationTitle("Rapporto per il medico")
        .navigationBarTitleDisplayMode(.inline)
        .task(id: report) {
            file = nil
            file = try? ReportPDF.file(for: report, now: clock.now, calendar: calendar)
        }
    }

    private func personSelection(current: Person?) -> Binding<UUID?> {
        Binding { current?.id } set: { personID = $0 }
    }

    private func inclusion(of id: UUID) -> Binding<Bool> {
        Binding {
            !excluded.contains(id)
        } set: { isOn in
            if isOn { excluded.remove(id) } else { excluded.insert(id) }
        }
    }
}

#Preview("Light") {
    NavigationStack {
        ReportView()
    }
    .modelContainer(.preview)
    .environment(Clock())
    .tint(SbuTheme.accentMeds)
}

#Preview("Dark") {
    NavigationStack {
        ReportView()
    }
    .modelContainer(.preview)
    .environment(Clock())
    .tint(SbuTheme.accentMeds)
    .preferredColorScheme(.dark)
}
