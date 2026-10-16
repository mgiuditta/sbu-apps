import Foundation
import WidgetKit

/// The widget at one moment.
struct MedsEntry: TimelineEntry {
    let date: Date
    let content: WidgetContent

    /// For the gallery and the placeholder: made-up, never the user's own.
    static func sample(date: Date = .now) -> MedsEntry {
        let calendar = Calendar.current
        func item(_ hour: Int, _ name: LocalizedStringResource, _ amount: String, _ person: LocalizedStringResource, late: Bool = false) -> WidgetContent.Item {
            let due = calendar.date(bySettingHour: hour, minute: 0, second: 0, of: date) ?? date
            return WidgetContent.Item(dueDate: due, name: String(localized: name), amount: amount, personName: String(localized: person), isLate: late)
        }
        return MedsEntry(date: date, content: WidgetContent(
            toTakeCount: 4, lateCount: 1,
            items: [
                item(13, "Ferro", MedicineForm.tablet.amountText(1), "Io", late: true),
                item(14, "Sciroppo per la tosse", MedicineForm.liquid.amountText(5), "Luca"),
                item(20, "Omega 3", MedicineForm.capsule.amountText(1), "Io"),
                item(21, "Atorvastatina", MedicineForm.tablet.amountText(1), "Nonna Rita"),
            ],
            isEmpty: false
        ))
    }
}
