import Foundation
import SwiftData

/// Brings the 1.x history and folders into the store at first launch, silently (ADR-0010).
///
/// Every row goes to the history, codes made in the 1.x creator too, as the 1.x listed them there. The
/// 1.x file is never changed or deleted. Each code and folder keeps its 1.x id, so running again only
/// adds what's missing. A row that can't be read is skipped and counted: Impostazioni shows how many
/// and offers to try again.
enum LegacyMigration {
    struct Outcome: Equatable {
        var imported = 0
        var skipped = 0
        /// The file exists but couldn't be opened or read.
        var unreadable = false
    }

    enum Key {
        static let done = "legacyMigration.done"
        static let skipped = "legacyMigration.skipped"
        static let unreadable = "legacyMigration.unreadable"
    }

    /// Runs once; after a full success it never runs again on its own.
    @discardableResult
    static func runIfNeeded(_ context: ModelContext, documents: URL = .documentsDirectory, defaults: UserDefaults = .standard) -> Outcome? {
        guard !defaults.bool(forKey: Key.done) else { return nil }
        return run(context, documents: documents, defaults: defaults)
    }

    @discardableResult
    static func run(_ context: ModelContext, documents: URL = .documentsDirectory, defaults: UserDefaults = .standard) -> Outcome {
        let url = LegacyDatabase.url(in: documents)
        guard FileManager.default.fileExists(atPath: url.path(percentEncoded: false)) else {
            // A new install: nothing to bring over, ever.
            defaults.set(true, forKey: Key.done)
            return Outcome()
        }
        var outcome = Outcome()
        do {
            let legacy = try LegacyDatabase.read(at: url)
            var folders: [Int: ScanFolder] = [:]
            for folder in (try? context.fetch(FetchDescriptor<ScanFolder>())) ?? [] {
                if let id = folder.legacyID { folders[id] = folder }
            }
            for row in legacy.folders where folders[row.id] == nil {
                let name = row.name.trimmingCharacters(in: .whitespacesAndNewlines)
                let folder = ScanFolder(name: name.isEmpty ? String(localized: "Cartella") : name, created: LegacyConversion.date(row.createdAt) ?? .now)
                folder.legacyID = row.id
                context.insert(folder)
                folders[row.id] = folder
            }
            let existing = Set(((try? context.fetch(FetchDescriptor<ScanRecord>())) ?? []).compactMap(\.legacyID))
            for row in legacy.scans where !existing.contains(row.id) {
                guard !row.data.isEmpty, let date = LegacyConversion.date(row.scannedAt) else {
                    outcome.skipped += 1
                    continue
                }
                let record = ScanRecord(
                    raw: row.data,
                    symbology: LegacyConversion.symbology(row.symbology, codeType: row.codeType),
                    date: date,
                    folder: row.folderID.flatMap { folders[$0] }
                )
                record.legacyID = row.id
                context.insert(record)
                outcome.imported += 1
            }
            try context.save()
        } catch {
            outcome.unreadable = true
        }
        defaults.set(outcome.skipped, forKey: Key.skipped)
        defaults.set(outcome.unreadable, forKey: Key.unreadable)
        defaults.set(outcome.skipped == 0 && !outcome.unreadable, forKey: Key.done)
        return outcome
    }
}
