import Foundation
import SQLite3
import SwiftData
import Testing
@testable import SbuSubscriptions

/// A 1.0 database with its exact schema, written the way the Expo app wrote it: WAL, money as REAL,
/// dates as UTC `toISOString()`, the category as its Italian label.
nonisolated final class LegacyFixture {
    let documents: URL
    private var db: OpaquePointer?

    init() throws {
        documents = URL.temporaryDirectory.appending(path: "legacy-\(UUID().uuidString)")
        let folder = documents.appending(path: "SQLite")
        try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        sqlite3_open(folder.appending(path: "sbu_subscriptions.db").path(percentEncoded: false), &db)
        exec("PRAGMA journal_mode = WAL;")
        exec("""
            CREATE TABLE IF NOT EXISTS subscriptions (
              id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT NOT NULL, amount REAL NOT NULL, currency TEXT NOT NULL,
              billing_cycle TEXT NOT NULL, next_renewal_date TEXT NOT NULL, category TEXT, color TEXT, icon_slug TEXT,
              is_trial INTEGER NOT NULL DEFAULT 0, trial_ends_at TEXT, reminder_days_before INTEGER NOT NULL DEFAULT 1,
              notes TEXT, notification_id TEXT, created_at TEXT NOT NULL, updated_at TEXT NOT NULL);
            """)
    }

    func insert(_ values: String) {
        exec("""
            INSERT INTO subscriptions (name, amount, currency, billing_cycle, next_renewal_date, category, color, icon_slug,
              is_trial, trial_ends_at, reminder_days_before, notes, notification_id, created_at, updated_at) VALUES (\(values));
            """)
    }

    /// Left open on purpose: the rows stay in the -wal file, as when the 1.0 was killed.
    func exec(_ sql: String) {
        sqlite3_exec(db, sql, nil, nil, nil)
    }

    deinit {
        sqlite3_close(db)
        try? FileManager.default.removeItem(at: documents)
    }
}

struct LegacyMigrationTests {
    let calendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Europe/Rome")!
        return calendar
    }()
    let defaults = UserDefaults(suiteName: "LegacyMigrationTests.\(UUID().uuidString)")!

    func day(_ year: Int, _ month: Int, _ day: Int) -> Date {
        calendar.date(from: DateComponents(year: year, month: month, day: day))!
    }

    func context() throws -> ModelContext {
        let context = ModelContext(try ModelContainer.subscriptions(inMemory: true))
        try CategorySeeder.seed(context)
        return context
    }

    @Test func bringsEveryFieldOverFromTheWal() throws {
        let fixture = try LegacyFixture()
        fixture.insert("'Netflix', 12.990000000001, 'EUR', 'monthly', '2026-06-14T22:00:00.000Z', 'Streaming', '#E50914', 'netflix', 0, NULL, 3, 'Piano famiglia', 'expo-id', '2026-01-02T10:00:00.000Z', '2026-01-02T10:00:00.000Z'")
        fixture.insert("'Palestra', 120, 'CHF', 'quarterly', '2026-10-31T23:00:00.000Z', 'Sport', NULL, NULL, 1, '2026-10-31T23:00:00.000Z', -1, NULL, NULL, '2026-01-02T10:00:00.000Z', '2026-01-02T10:00:00.000Z'")
        let context = try context()

        let outcome = LegacyMigration.run(context, documents: fixture.documents, defaults: defaults, calendar: calendar)
        #expect(outcome == .init(imported: 2, skipped: 0, unreadable: false))
        #expect(defaults.bool(forKey: LegacyMigration.Key.done))

        let all = try context.fetch(FetchDescriptor<Subscription>())
        let netflix = try #require(all.first { $0.name == "Netflix" })
        #expect(netflix.price == Decimal(string: "12.99"))
        #expect(netflix.startDate == day(2026, 6, 15), "UTC midnight of the 14th is the 15th in Rome")
        #expect(netflix.cycle == .monthly)
        #expect(netflix.reminderDaysBefore == 3)
        #expect(netflix.category?.key == "streaming")
        #expect(netflix.serviceID == "netflix")
        #expect(netflix.notes == "Piano famiglia")
        #expect(netflix.legacyID == 1)

        let gym = try #require(all.first { $0.name == "Palestra" })
        #expect(gym.cycle == .every(3, .month))
        #expect(gym.trialEndDate == day(2026, 11, 1))
        #expect(gym.startDate == day(2026, 11, 1))
        #expect(gym.reminderDaysBefore == nil)
        #expect(gym.currencyCode == "CHF")
        #expect(gym.category?.name == "Sport", "An unknown 1.0 label becomes a category of its own")
    }

    @Test func badRowIsSkippedAndCountedTheOthersArrive() throws {
        let fixture = try LegacyFixture()
        fixture.insert("'Musica', 10.99, 'EUR', 'monthly', '2026-06-14T22:00:00.000Z', 'Musica', NULL, NULL, 0, NULL, 1, NULL, NULL, '2026-01-02T10:00:00.000Z', '2026-01-02T10:00:00.000Z'")
        fixture.insert("'Rotto', 5, 'EUR', 'fortnightly', 'not a date', NULL, NULL, NULL, 0, NULL, 1, NULL, NULL, '', ''")
        let context = try context()

        let outcome = LegacyMigration.run(context, documents: fixture.documents, defaults: defaults, calendar: calendar)
        #expect(outcome.imported == 1)
        #expect(outcome.skipped == 1)
        #expect(!defaults.bool(forKey: LegacyMigration.Key.done), "Not done: Impostazioni offers to try again")
        #expect(defaults.integer(forKey: LegacyMigration.Key.skipped) == 1)
    }

    @Test func runningAgainNeverAddsCopies() throws {
        let fixture = try LegacyFixture()
        fixture.insert("'Musica', 10.99, 'EUR', 'monthly', '2026-06-14T22:00:00.000Z', 'Musica', NULL, NULL, 0, NULL, 1, NULL, NULL, '2026-01-02T10:00:00.000Z', '2026-01-02T10:00:00.000Z'")
        let context = try context()
        LegacyMigration.run(context, documents: fixture.documents, defaults: defaults, calendar: calendar)
        LegacyMigration.run(context, documents: fixture.documents, defaults: defaults, calendar: calendar)
        #expect(try context.fetchCount(FetchDescriptor<Subscription>()) == 1)
    }

    @Test func newInstallHasNothingToBringOver() throws {
        let documents = URL.temporaryDirectory.appending(path: "empty-\(UUID().uuidString)")
        let outcome = LegacyMigration.runIfNeeded(try context(), documents: documents, defaults: defaults, calendar: calendar)
        #expect(outcome == .init())
        #expect(defaults.bool(forKey: LegacyMigration.Key.done))
        #expect(LegacyMigration.runIfNeeded(try context(), documents: documents, defaults: defaults, calendar: calendar) == nil)
    }

    @Test func mainCurrencyFollowsTheMostUsedUnlessChosen() throws {
        let fixture = try LegacyFixture()
        for _ in 0..<2 {
            fixture.insert("'A', 1, 'USD', 'monthly', '2026-06-14T22:00:00.000Z', NULL, NULL, NULL, 0, NULL, 1, NULL, NULL, '2026-01-02T10:00:00.000Z', '2026-01-02T10:00:00.000Z'")
        }
        fixture.insert("'B', 1, 'EUR', 'monthly', '2026-06-14T22:00:00.000Z', NULL, NULL, NULL, 0, NULL, 1, NULL, NULL, '2026-01-02T10:00:00.000Z', '2026-01-02T10:00:00.000Z'")
        let currency = CurrencySettings(defaults: defaults, locale: Locale(identifier: "it_IT"))
        LegacyMigration.run(try context(), documents: fixture.documents, defaults: defaults, currency: currency, calendar: calendar)
        #expect(currency.mainCurrency == "USD")
    }

    @Test(arguments: [(9.99, "9.99"), (9.990000000001, "9.99"), (1000.0, "1000"), (0.1 + 0.2, "0.3")])
    func pricesLoseTheDoubleNoise(amount: Double, expected: String) {
        #expect(LegacyConversion.price(amount) == Decimal(string: expected))
    }
}
