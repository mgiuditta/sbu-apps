import SbuKit
import SwiftData
import SwiftUI

/// What a CSV file holds, row by row, before anything is saved: you choose which rows to import.
/// Rows that match a subscription you already have start unticked; rows that can't be read say why.
struct CSVReviewView: View {
    let file: CSVImport

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query private var existing: [Subscription]
    @Query(sort: \SubscriptionCategory.order) private var categories: [SubscriptionCategory]
    @Query(sort: \SubscriptionList.order) private var lists: [SubscriptionList]
    @State private var selected: Set<Int>

    init(file: CSVImport, existing: [Subscription]) {
        self.file = file
        let known = Set(existing.map(Self.key))
        _selected = State(initialValue: Set(file.rows.compactMap { row in
            guard case let .success(candidate) = row.result, !known.contains(Self.key(candidate)) else { return nil }
            return row.id
        }))
    }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    ForEach(file.rows) { row in
                        if case let .success(candidate) = row.result {
                            Toggle(isOn: binding(row.id)) {
                                VStack(alignment: .leading) {
                                    Text(candidate.name)
                                    Text("\(candidate.price.formatted(.currency(code: candidate.currencyCode))) · \(Text(candidate.cycle.label))")
                                        .font(SbuTheme.subheadline)
                                        .foregroundStyle(SbuTheme.inkMuted)
                                    if isDuplicate(candidate) {
                                        Text("Già presente")
                                            .font(SbuTheme.footnote)
                                            .foregroundStyle(SbuTheme.inkMuted)
                                    }
                                }
                            }
                        }
                    }
                }
                let problems = file.rows.compactMap { row -> (Int, CSVImport.Problem)? in
                    guard case let .failure(problem) = row.result else { return nil }
                    return (row.line, problem)
                }
                if !problems.isEmpty {
                    Section("Righe non importabili") {
                        ForEach(problems, id: \.0) { line, problem in
                            Label(message(line: line, problem: problem), systemImage: "exclamationmark.triangle")
                                .foregroundStyle(SbuTheme.warning)
                        }
                    }
                }
            }
            .navigationTitle("Importa CSV")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annulla") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Importa \(selected.count)", action: importSelected)
                        .disabled(selected.isEmpty)
                        .accessibilityIdentifier("importSelected")
                }
            }
        }
    }

    private func binding(_ id: Int) -> Binding<Bool> {
        Binding { selected.contains(id) } set: { isOn in
            if isOn { selected.insert(id) } else { selected.remove(id) }
        }
    }

    private func isDuplicate(_ candidate: CSVImport.Candidate) -> Bool {
        existing.contains { Self.key($0) == Self.key(candidate) }
    }

    private static func key(_ subscription: Subscription) -> String {
        "\(subscription.name.lowercased())|\(subscription.price)|\(subscription.currencyCode)"
    }

    private static func key(_ candidate: CSVImport.Candidate) -> String {
        "\(candidate.name.lowercased())|\(candidate.price)|\(candidate.currencyCode)"
    }

    private func message(line: Int, problem: CSVImport.Problem) -> LocalizedStringKey {
        switch problem {
        case .noName: "Riga \(line): manca il nome"
        case let .badPrice(text): "Riga \(line): prezzo non valido «\(text)»"
        case let .badCycle(text): "Riga \(line): ciclo non riconosciuto «\(text)»"
        case let .badDate(text): "Riga \(line): data non valida «\(text)»"
        }
    }

    private func importSelected() {
        var categories = categories
        var lists = lists
        for row in file.rows where selected.contains(row.id) {
            guard case let .success(candidate) = row.result else { continue }
            let subscription = Subscription(name: candidate.name, price: candidate.price, currencyCode: candidate.currencyCode, startDate: candidate.date, cycle: candidate.cycle)
            subscription.trialEndDate = candidate.trialEnd
            subscription.notes = candidate.notes
            subscription.status = candidate.status
            subscription.reminderDaysBefore = candidate.reminderDaysBefore
            subscription.paymentMethod = candidate.paymentMethod
            subscription.url = candidate.website
            if let name = candidate.category {
                subscription.category = categories.first { $0.name.localizedCaseInsensitiveCompare(name) == .orderedSame }
                    ?? BuiltInCategory(legacyLabel: name).flatMap { key in categories.first { $0.key == key.rawValue } }
                    ?? {
                        let category = SubscriptionCategory(customName: name, symbol: BuiltInCategory.other.symbol, order: (categories.map(\.order).max() ?? 0) + 1)
                        modelContext.insert(category)
                        categories.append(category)
                        return category
                    }()
            }
            if let name = candidate.list {
                subscription.list = lists.first { $0.name.localizedCaseInsensitiveCompare(name) == .orderedSame } ?? {
                    let list = SubscriptionList(name: name, order: (lists.map(\.order).max() ?? 0) + 1)
                    modelContext.insert(list)
                    lists.append(list)
                    return list
                }()
            }
            modelContext.insert(subscription)
        }
        try? modelContext.save()
        dismiss()
    }
}
