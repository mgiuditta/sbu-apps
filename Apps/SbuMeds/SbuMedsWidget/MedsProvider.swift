import Foundation
import SwiftData
import WidgetKit

/// Reads the app's store from the App Group and lays out the rest of the day: each dose turns
/// late at its time and a new day starts at midnight without anyone opening the app. The app
/// also reloads the widget after every save.
struct MedsProvider: TimelineProvider {
    /// Midnights computed ahead; the system asks again after the last one.
    static let days = 2
    /// Rows the largest family has room for.
    static let itemLimit = 5

    func placeholder(in context: Context) -> MedsEntry {
        .sample()
    }

    func getSnapshot(in context: Context, completion: @escaping (MedsEntry) -> Void) {
        if context.isPreview {
            completion(.sample())
            return
        }
        Task { @MainActor in
            completion(Self.entries(from: .now).first ?? .sample())
        }
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<MedsEntry>) -> Void) {
        Task { @MainActor in
            completion(Timeline(entries: Self.entries(from: .now), policy: .atEnd))
        }
    }

    @MainActor
    static func entries(from now: Date, calendar: Calendar = .current) -> [MedsEntry] {
        let medicines = (try? ModelContainer.meds()).flatMap { try? ModelContext($0).fetch(FetchDescriptor<Medicine>()) } ?? []
        let snapshots = medicines.map(\.snapshot)
        return WidgetContent.moments(for: snapshots, from: now, calendar: calendar, days: days).map { moment in
            MedsEntry(date: moment, content: WidgetContent(snapshots, at: moment, calendar: calendar, limit: itemLimit))
        }
    }
}
