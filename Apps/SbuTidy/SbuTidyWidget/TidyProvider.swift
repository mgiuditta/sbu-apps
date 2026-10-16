import Foundation
import SwiftData
import WidgetKit

/// Reads the app's store from the App Group and lays out the next days: chores turn due at
/// midnight without anyone opening the app. The app also reloads the widget after every save.
struct TidyProvider: TimelineProvider {
    /// Midnights computed ahead; the system asks again after the last one.
    static let days = 3
    /// Rows the largest family has room for.
    static let itemLimit = 5

    func placeholder(in context: Context) -> TidyEntry {
        .sample()
    }

    func getSnapshot(in context: Context, completion: @escaping (TidyEntry) -> Void) {
        if context.isPreview {
            completion(.sample())
            return
        }
        Task { @MainActor in
            completion(Self.entries(from: .now).first ?? .sample())
        }
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<TidyEntry>) -> Void) {
        Task { @MainActor in
            completion(Timeline(entries: Self.entries(from: .now), policy: .atEnd))
        }
    }

    @MainActor
    static func entries(from now: Date, calendar: Calendar = .current) -> [TidyEntry] {
        let chores = (try? ModelContainer.tidy()).flatMap { try? ModelContext($0).fetch(FetchDescriptor<Chore>()) } ?? []
        let snapshots = chores.map(\.snapshot)
        return WidgetContent.moments(from: now, calendar: calendar, days: days).map { moment in
            TidyEntry(date: moment, content: WidgetContent(snapshots, at: moment, calendar: calendar, limit: itemLimit))
        }
    }
}
