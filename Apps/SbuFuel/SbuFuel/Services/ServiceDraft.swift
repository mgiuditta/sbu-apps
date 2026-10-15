import Foundation

/// The form of a service done, as typed.
nonisolated struct ServiceDraft: Equatable, Sendable {
    var kind = ServiceKind.oilChange
    var title = ""
    var date = Date.now
    var odometerText = ""
    var costText = ""
    var note = ""
    var distanceUnit: DistanceUnit
    var locale: Locale

    init(distanceUnit: DistanceUnit, locale: Locale = .current) {
        self.distanceUnit = distanceUnit
        self.locale = locale
    }

    var trimmedTitle: String {
        title.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    /// The reading, if typed: a service can be logged without one, as a tax or an insurance.
    var odometerKm: Double? {
        NumberText.double(odometerText, locale: locale).flatMap { $0 > 0 ? distanceUnit.km(from: $0) : nil }
    }

    var cost: Decimal {
        NumberText.decimal(costText, locale: locale).flatMap { $0 >= 0 ? $0 : nil } ?? 0
    }

    /// A typed reading that is not a number blocks saving; an empty one does not.
    var canSave: Bool {
        !trimmedTitle.isEmpty && (odometerText.trimmingCharacters(in: .whitespaces).isEmpty || odometerKm != nil)
    }
}
