import Foundation
import SwiftData

extension ModelContainer {
    /// An in-memory store with the sample family, for previews and screenshots.
    static let preview: ModelContainer = {
        do {
            let container = try meds(inMemory: true)
            SampleFamily.insert(into: container.mainContext, now: .now, calendar: .current)
            try container.mainContext.save()
            return container
        } catch {
            fatalError("Preview store failed to open: \(error)")
        }
    }()
}
