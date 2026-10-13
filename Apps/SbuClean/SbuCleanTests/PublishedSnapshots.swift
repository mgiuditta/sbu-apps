import os
@testable import SbuClean

/// Collects what the model hands to the widget.
nonisolated final class PublishedSnapshots: Sendable {
    private let lock = OSAllocatedUnfairLock<[WidgetSnapshot]>(initialState: [])

    var values: [WidgetSnapshot] {
        lock.withLock { $0 }
    }

    @Sendable
    func append(_ snapshot: WidgetSnapshot) {
        lock.withLock { $0.append(snapshot) }
    }
}
