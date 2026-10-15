import Foundation

/// The form of a service reminder: every so many kilometres, months, or both, from the last time.
nonisolated struct ReminderDraft: Equatable, Sendable {
    enum Problem: Equatable, Sendable {
        /// Neither a distance nor a time.
        case noInterval
        /// A distance without the reading it was last done at.
        case missingLastReading
    }

    var kind = ServiceKind.oilChange
    var title = ""
    var everyKmText = ""
    /// 0 means no time interval.
    var everyMonths = 0
    var lastDoneDate = Date.now
    var lastOdometerText = ""
    var distanceUnit: DistanceUnit
    var locale: Locale

    init(distanceUnit: DistanceUnit, locale: Locale = .current) {
        self.distanceUnit = distanceUnit
        self.locale = locale
    }

    var trimmedTitle: String {
        title.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var everyKm: Double? {
        NumberText.double(everyKmText, locale: locale).flatMap { $0 > 0 ? distanceUnit.km(from: $0) : nil }
    }

    var lastOdometerKm: Double? {
        NumberText.double(lastOdometerText, locale: locale).flatMap { $0 > 0 ? distanceUnit.km(from: $0) : nil }
    }

    var problem: Problem? {
        if everyKm == nil, everyMonths == 0 { return .noInterval }
        if everyKm != nil, lastOdometerKm == nil { return .missingLastReading }
        return nil
    }

    var canSave: Bool {
        !trimmedTitle.isEmpty && problem == nil
    }

    /// Fills name and intervals from a preset, in the vehicle's unit, rounded to a round number of miles.
    mutating func apply(_ kind: ServiceKind) {
        self.kind = kind
        title = kind == .custom ? "" : String(localized: kind.name)
        if let km = kind.presetEveryKm {
            let value = distanceUnit == .kilometres ? km : (distanceUnit.value(fromKm: km) / 500).rounded() * 500
            everyKmText = NumberText.text(value, fractionDigits: 0...0, locale: locale)
        } else {
            everyKmText = ""
        }
        everyMonths = kind.presetEveryMonths ?? 0
    }
}
