import Foundation
import SwiftData

/// A vehicle you log fuel-ups and services for. Free text, no make or model database.
@Model
final class Vehicle {
    var id = UUID()
    var name = ""
    var kindRaw = VehicleKind.car.rawValue
    var fuelTypeRaw = FuelType.petrol.rawValue
    /// The odometer's unit, fixed once the vehicle has entries.
    var odometerUnitRaw = DistanceUnit.kilometres.rawValue
    var tankLitres: Double?
    var plate = ""
    var vin = ""
    var createdAt = Date.now

    @Relationship(deleteRule: .cascade, inverse: \FuelUp.vehicle) var fuelUps: [FuelUp]? = []
    @Relationship(deleteRule: .cascade, inverse: \ServiceEntry.vehicle) var services: [ServiceEntry]? = []
    @Relationship(deleteRule: .cascade, inverse: \ServiceReminder.vehicle) var reminders: [ServiceReminder]? = []

    init(name: String, kind: VehicleKind = .car, fuelType: FuelType = .petrol, odometerUnit: DistanceUnit = .kilometres) {
        self.name = name
        kindRaw = kind.rawValue
        fuelTypeRaw = fuelType.rawValue
        odometerUnitRaw = odometerUnit.rawValue
    }

    var kind: VehicleKind {
        get { VehicleKind(rawValue: kindRaw) ?? .other }
        set { kindRaw = newValue.rawValue }
    }

    var fuelType: FuelType {
        get { FuelType(rawValue: fuelTypeRaw) ?? .other }
        set { fuelTypeRaw = newValue.rawValue }
    }

    var odometerUnit: DistanceUnit {
        get { DistanceUnit(rawValue: odometerUnitRaw) ?? .kilometres }
        set { odometerUnitRaw = newValue.rawValue }
    }

    var hasEntries: Bool {
        !(fuelUps ?? []).isEmpty || !(services ?? []).isEmpty
    }

    /// The fuel-ups as the calculators see them.
    var fillRecords: [FillRecord] {
        (fuelUps ?? []).map(\.record)
    }

    /// The highest odometer reading of any entry, in kilometres.
    var lastOdometerKm: Double? {
        let readings = (fuelUps ?? []).map(\.odometerKm) + (services ?? []).compactMap(\.odometerKm)
        return readings.max()
    }
}
