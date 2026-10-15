import SwiftData

/// The first shape of the store: vehicles with their fuel-ups, services and reminders.
/// Every attribute has a default and every relationship is optional, so iCloud can mirror it later.
enum FuelSchemaV1: VersionedSchema {
    static let versionIdentifier = Schema.Version(1, 0, 0)

    static var models: [any PersistentModel.Type] {
        [Vehicle.self, FuelUp.self, ServiceEntry.self, ServiceReminder.self]
    }
}
