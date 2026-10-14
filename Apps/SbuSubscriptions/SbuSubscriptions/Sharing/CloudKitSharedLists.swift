import CloudKit
import Foundation

/// The shared lists in CloudKit, both sides, in the app's container (the same as Sincronizza con iCloud,
/// in zones of their own). The owner keeps each shared list in a zone named after it in the private
/// database, holding one record with the snapshot, shared whole and read only; deleting the zone deletes
/// the share. People who accept see the zone in their shared database. Nothing passes through sbu.dev
/// (ADR-0009). Every call runs off the main actor.
nonisolated struct CloudKitSharedLists: SharedListsOutbox, SharedListsInbox {
    static let containerIdentifier = "iCloud.dev.sbu.subscriptions"
    static let recordType = "SharedList"
    static let recordName = "list"
    static let snapshotField = "snapshot"
    static let zonePrefix = "list-"
    static let subscriptionID = "shared-lists"

    private var container: CKContainer {
        CKContainer(identifier: Self.containerIdentifier)
    }

    // MARK: - Owner

    @concurrent
    func isAccountAvailable() async -> Bool {
        (try? await container.accountStatus()) == .available
    }

    @concurrent
    func sharedLists() async throws -> [UUID: Int] {
        let database = container.privateCloudDatabase
        let zones = try await database.allRecordZones().compactMap { zone in
            Self.listID(of: zone.zoneID).map { (listID: $0, zoneID: zone.zoneID) }
        }
        guard !zones.isEmpty else { return [:] }
        let shares = try await database.records(for: zones.map { Self.shareID(in: $0.zoneID) })
        var result: [UUID: Int] = [:]
        for zone in zones {
            // A zone without its share was being made or unshared: not shared.
            guard case .success(let record)? = shares[Self.shareID(in: zone.zoneID)], let share = record as? CKShare else { continue }
            result[zone.listID] = share.participants.count { $0.role != .owner && $0.acceptanceStatus != .removed }
        }
        return result
    }

    @concurrent
    func prepareShare(of listID: UUID, title: String, snapshot: Data) async throws -> CKShare {
        let database = container.privateCloudDatabase
        let zoneID = Self.zoneID(of: listID)
        if let existing = try? await database.record(for: Self.shareID(in: zoneID)) as? CKShare {
            try await publish(snapshot, of: listID)
            return existing
        }
        _ = try await database.modifyRecordZones(saving: [CKRecordZone(zoneID: zoneID)], deleting: [])
        let share = CKShare(recordZoneID: zoneID)
        share[CKShare.SystemFieldKey.title] = title
        share.publicPermission = .none
        let record = Self.record(snapshot, in: zoneID)
        let (saved, _) = try await database.modifyRecords(saving: [record, share], deleting: [], savePolicy: .allKeys)
        _ = try saved[record.recordID]?.get()
        guard let savedShare = try saved[share.recordID]?.get() as? CKShare else { return share }
        return savedShare
    }

    @concurrent
    func publish(_ snapshot: Data, of listID: UUID) async throws {
        let record = Self.record(snapshot, in: Self.zoneID(of: listID))
        do {
            // The owner's devices are the only writers: the newest snapshot replaces the record.
            let (saved, _) = try await container.privateCloudDatabase.modifyRecords(saving: [record], deleting: [], savePolicy: .allKeys)
            _ = try saved[record.recordID]?.get()
        } catch let error as CKError where Self.isGone(error) {
            throw SharingFailure.notShared
        }
    }

    @concurrent
    func stopSharing(_ listID: UUID) async throws {
        do {
            _ = try await container.privateCloudDatabase.modifyRecordZones(saving: [], deleting: [Self.zoneID(of: listID)])
        } catch let error as CKError where Self.isGone(error) {
            // Already gone.
        }
    }

    // MARK: - Recipient

    @concurrent
    func accept(_ metadata: CKShare.Metadata) async throws {
        _ = try await CKContainer(identifier: metadata.containerIdentifier).accept(metadata)
    }

    @concurrent
    func fetchAll() async throws -> [FetchedShare] {
        let database = container.sharedCloudDatabase
        let zoneIDs = try await database.allRecordZones().map(\.zoneID).filter { Self.listID(of: $0) != nil }
        guard !zoneIDs.isEmpty else { return [] }
        let recordIDs = zoneIDs.map { CKRecord.ID(recordName: Self.recordName, zoneID: $0) }
        let records = try await database.records(for: recordIDs)
        return recordIDs.map { recordID in
            let data = (try? records[recordID]?.get())?[Self.snapshotField] as? Data
            return FetchedShare(key: Self.key(of: recordID.zoneID), snapshot: data.flatMap { try? SharedListSnapshot.decode($0) })
        }
    }

    @concurrent
    func leave(_ key: String) async throws {
        guard let zoneID = Self.zoneID(fromKey: key) else { return }
        do {
            // A participant leaves by deleting the share from its shared database.
            let (_, deleted) = try await container.sharedCloudDatabase.modifyRecords(saving: [], deleting: [Self.shareID(in: zoneID)])
            for result in deleted.values { try result.get() }
        } catch let error as CKError where Self.isGone(error) {
            // Already left, or the owner stopped sharing.
        }
    }

    @concurrent
    func subscribe() async throws {
        let subscription = CKDatabaseSubscription(subscriptionID: Self.subscriptionID)
        let info = CKSubscription.NotificationInfo()
        // Silent: wakes the app to refresh, never shows anything.
        info.shouldSendContentAvailable = true
        subscription.notificationInfo = info
        _ = try await container.sharedCloudDatabase.save(subscription)
    }

    // MARK: - Names

    static func zoneID(of listID: UUID) -> CKRecordZone.ID {
        CKRecordZone.ID(zoneName: zonePrefix + listID.uuidString, ownerName: CKCurrentUserDefaultName)
    }

    static func listID(of zoneID: CKRecordZone.ID) -> UUID? {
        guard zoneID.zoneName.hasPrefix(zonePrefix) else { return nil }
        return UUID(uuidString: String(zoneID.zoneName.dropFirst(zonePrefix.count)))
    }

    /// A shared zone as `ReceivedList.key` names it: its owner and its name.
    static func key(of zoneID: CKRecordZone.ID) -> String {
        "\(zoneID.ownerName)|\(zoneID.zoneName)"
    }

    static func zoneID(fromKey key: String) -> CKRecordZone.ID? {
        let parts = key.split(separator: "|", maxSplits: 1).map(String.init)
        guard parts.count == 2 else { return nil }
        return CKRecordZone.ID(zoneName: parts[1], ownerName: parts[0])
    }

    private static func shareID(in zoneID: CKRecordZone.ID) -> CKRecord.ID {
        CKRecord.ID(recordName: CKRecordNameZoneWideShare, zoneID: zoneID)
    }

    private static func record(_ snapshot: Data, in zoneID: CKRecordZone.ID) -> CKRecord {
        let record = CKRecord(recordType: recordType, recordID: CKRecord.ID(recordName: recordName, zoneID: zoneID))
        record[snapshotField] = snapshot as NSData
        return record
    }

    private static func isGone(_ error: CKError) -> Bool {
        switch error.code {
        case .zoneNotFound, .userDeletedZone, .unknownItem: true
        case .partialFailure:
            error.partialErrorsByItemID?.values.allSatisfy { ($0 as? CKError).map(isGone) ?? false } ?? false
        default: false
        }
    }
}
