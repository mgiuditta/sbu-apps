import Foundation

/// A medicine as plain values: what the pure day plan, reminders, report and widget read.
nonisolated struct MedicineSnapshot: Hashable, Sendable, Identifiable {
    let id: UUID
    let personID: UUID
    let personName: String
    let name: String
    let form: MedicineForm
    let strength: String
    let schedule: Schedule
    let asNeededAmount: Double
    let stock: Double?
    let refillThreshold: Double?
    let records: [DoseRecordSnapshot]

    init(
        id: UUID = UUID(),
        personID: UUID = UUID(),
        personName: String = "",
        name: String,
        form: MedicineForm = .tablet,
        strength: String = "",
        schedule: Schedule,
        asNeededAmount: Double = 1,
        stock: Double? = nil,
        refillThreshold: Double? = nil,
        records: [DoseRecordSnapshot] = []
    ) {
        self.id = id
        self.personID = personID
        self.personName = personName
        self.name = name
        self.form = form
        self.strength = strength
        self.schedule = schedule
        self.asNeededAmount = asNeededAmount
        self.stock = stock
        self.refillThreshold = refillThreshold
        self.records = records
    }

    var stockLevel: StockLevel { StockLevel(stock: stock, threshold: refillThreshold) }

    /// "1 compressa · 500 mg".
    func detail(amount: Double, locale: Locale = .current) -> String {
        let text = form.amountText(amount, locale: locale)
        return strength.isEmpty ? text : "\(text) · \(strength)"
    }
}
