import Foundation
import SwiftData

extension ModelContainer {
    /// An in-memory store with the sample home, for previews and screenshots.
    static let preview: ModelContainer = {
        do {
            let container = try tidy(inMemory: true)
            SampleHome.insert(into: container.mainContext, now: .now, calendar: .current)
            return container
        } catch {
            fatalError("Preview store failed to open: \(error)")
        }
    }()
}
