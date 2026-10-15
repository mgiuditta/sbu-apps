import Foundation

/// The add and edit form of a vehicle, as typed.
nonisolated struct VehicleDraft: Equatable, Sendable {
    var name = ""
    var kind = VehicleKind.car
    var fuelType = FuelType.petrol
    var odometerUnit: DistanceUnit
    /// The tank's capacity in the chosen volume unit; empty when you don't know it.
    var tankText = ""
    var plate = ""
    var vin = ""
    var volumeUnit: VolumeUnit
    var locale: Locale

    init(odometerUnit: DistanceUnit, volumeUnit: VolumeUnit, locale: Locale = .current) {
        self.odometerUnit = odometerUnit
        self.volumeUnit = volumeUnit
        self.locale = locale
    }

    var trimmedName: String {
        name.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var canSave: Bool {
        !trimmedName.isEmpty
    }

    /// The tank in litres, if typed.
    var tankLitres: Double? {
        NumberText.double(tankText, locale: locale).flatMap { $0 > 0 ? volumeUnit.litres(from: $0) : nil }
    }
}
