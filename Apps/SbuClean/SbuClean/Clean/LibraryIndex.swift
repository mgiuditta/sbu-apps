import Foundation

/// The library ready for the screens: items with their cached sizes, by identifier, by month.
/// Built off the main actor, because a library can hold tens of thousands of items.
nonisolated struct LibraryIndex: Sendable {
    var items: [MediaItem] = []
    var byID: [String: MediaItem] = [:]
    var monthOf: [String: YearMonth] = [:]
    var unmeasuredCount = 0

    init() {}

    /// Indexes the items, filling in the sizes measured before.
    init(items fetched: [MediaItem], sizes: [String: ItemSize], calendar: Calendar = .current) {
        var items = fetched
        for index in items.indices where items[index].size == nil {
            if let size = sizes[items[index].id], size.modified == items[index].modificationDate {
                items[index].size = size
            }
        }
        self.init(indexing: items, calendar: calendar)
    }

    /// Indexes items as they are.
    init(indexing items: [MediaItem], calendar: Calendar = .current) {
        self.items = items
        byID.reserveCapacity(items.count)
        monthOf.reserveCapacity(items.count)
        for item in items {
            if byID[item.id] == nil {
                byID[item.id] = item
            }
            if let date = item.creationDate {
                monthOf[item.id] = YearMonth(date, calendar: calendar)
            }
            if item.size == nil {
                unmeasuredCount += 1
            }
        }
    }

    /// The same items with newly measured sizes.
    func applying(_ measured: [String: ItemSize]) -> LibraryIndex {
        var copy = self
        for index in copy.items.indices {
            if let size = measured[copy.items[index].id] {
                copy.items[index].size = size
                copy.byID[copy.items[index].id] = copy.items[index]
                copy.unmeasuredCount -= 1
            }
        }
        return copy
    }

    /// The same index without some items.
    func removing(_ ids: Set<String>) -> LibraryIndex {
        var copy = self
        copy.items.removeAll { ids.contains($0.id) }
        for id in ids {
            if let item = copy.byID.removeValue(forKey: id), item.size == nil {
                copy.unmeasuredCount -= 1
            }
            copy.monthOf[id] = nil
        }
        return copy
    }
}
