import Foundation
import SwiftData

extension ModelContainer {
    static let subscriptionsAppGroup = "group.dev.sbu.subscriptions"
    static let subscriptionsCloudContainer = "iCloud.dev.sbu.subscriptions"
    /// Settings → Dati → Sincronizza con iCloud, in the App Group defaults; read at launch.
    static let iCloudSyncKey = "iCloudSync"

    /// The subscriptions store, in the App Group so the widget reads the same data. Mirrored to the
    /// user's private CloudKit database only when they turned sync on (ADR-0008); the widget and the
    /// other read-only callers pass `syncsWithICloud: false`, so an extension never syncs on its own.
    static func subscriptions(inMemory: Bool = false, syncsWithICloud: Bool? = nil) throws -> ModelContainer {
        let schema = Schema(versionedSchema: SubscriptionsSchemaV1.self)
        let syncs = !inMemory && (syncsWithICloud ?? UserDefaults.appGroup.bool(forKey: iCloudSyncKey))
        let configuration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: inMemory,
            groupContainer: inMemory ? .none : .identifier(subscriptionsAppGroup),
            cloudKitDatabase: syncs ? .private(subscriptionsCloudContainer) : .none
        )
        return try ModelContainer(for: schema, migrationPlan: SubscriptionsMigrationPlan.self, configurations: configuration)
    }
}
