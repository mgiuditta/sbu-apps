import SwiftData

extension ModelContainer {
    /// An in-memory store with the sample house, for previews.
    static let preview: ModelContainer = {
        // ponytail: previews only; an in-memory store with the shipped schema does not fail.
        let container = try! ModelContainer.inventory(inMemory: true)
        InventorySample.insert(into: container.mainContext, wrapped: false)
        return container
    }()
}
