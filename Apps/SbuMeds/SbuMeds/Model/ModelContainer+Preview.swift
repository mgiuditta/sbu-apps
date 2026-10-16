import Foundation
import SwiftData

extension ModelContainer {
    /// An in-memory store with the sample family, for previews.
    static let preview = sample(now: .now)

    /// An in-memory store with the sample family as it stands at `now`: previews and screenshots.
    static func sample(now: Date) -> ModelContainer {
        do {
            let container = try meds(inMemory: true)
            SampleFamily.insert(into: container.mainContext, now: now, calendar: .current)
            try container.mainContext.save()
            return container
        } catch {
            fatalError("Sample store failed to open: \(error)")
        }
    }
}
