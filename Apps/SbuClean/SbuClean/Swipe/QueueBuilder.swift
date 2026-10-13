import Foundation

/// Builds the swipe queues and the month-by-month timeline from the library and the decisions.
///
/// Items in the bin or kept forever never show up in a queue; items already decided leave the
/// queues too, so a month picks up where the user stopped.
nonisolated struct QueueBuilder {
    /// How far back Recenti goes.
    static let recentDays = 30
    /// How many items Casuale deals.
    static let randomCount = 50

    /// The library, newest first.
    let items: [MediaItem]
    let state: CleanState
    var now = Date.now
    var calendar = Calendar.current

    /// The identifiers to swipe for a source, in the order to show them.
    /// - Parameters:
    ///   - source: Where the queue comes from.
    ///   - albumItemIDs: The album's items, newest first, for `.album`.
    ///   - seed: The shuffle of `.random`.
    func queue(for source: SwipeSource, albumItemIDs: [String] = [], seed: UInt64 = .random(in: .min ... .max)) -> [String] {
        switch source {
        case .recent:
            return recentItems.map(\.id)
        case .random:
            var generator = SeededGenerator(seed: seed)
            return Array(undecided.shuffled(using: &generator).prefix(Self.randomCount)).map(\.id)
        case .onThisDay:
            return onThisDayItems.map(\.id)
        case .later:
            return items.filter { state.later.contains($0.id) }.map(\.id)
        case .month(let month):
            return undecided.filter { item in
                item.creationDate.map { YearMonth($0, calendar: calendar) } == month
            }
            .reversed()
            .map(\.id)
        case .album:
            let open = Set(undecided.map(\.id))
            return albumItemIDs.filter(open.contains)
        case .category(let category):
            return undecided
                .filter { $0.belongs(to: category) }
                .sorted { $0.bytes > $1.bytes }
                .map(\.id)
        }
    }

    /// Items of the last 30 days still to see: the badge of Recenti.
    var recentItems: [MediaItem] {
        guard let start = calendar.date(byAdding: .day, value: -Self.recentDays, to: now) else { return [] }

        return undecided.filter { ($0.creationDate ?? .distantPast) >= start }
    }

    /// Items taken on today's day and month in past years, still to see.
    var onThisDayItems: [MediaItem] {
        let today = calendar.dateComponents([.year, .month, .day], from: now)
        return undecided.filter { item in
            guard let date = item.creationDate else { return false }

            let components = calendar.dateComponents([.year, .month, .day], from: date)
            return components.month == today.month && components.day == today.day && components.year != today.year
        }
    }

    /// Every month with items, newest first, with how many are decided.
    func months() -> [MonthProgress] {
        let open = Set(undecided.map(\.id))
        var progress: [YearMonth: MonthProgress] = [:]
        for item in items {
            guard let date = item.creationDate else { continue }

            let month = YearMonth(date, calendar: calendar)
            progress[month, default: MonthProgress(month: month, total: 0, decided: 0)].total += 1
            if !open.contains(item.id) {
                progress[month]?.decided += 1
            }
        }
        return progress.values.sorted { $0.month > $1.month }
    }

    /// Items with no decision yet, newest first.
    private var undecided: [MediaItem] {
        let trash = Set(state.trash)
        return items.filter { item in
            !trash.contains(item.id) && !state.keepForever.contains(item.id)
                && !state.kept.contains(item.id) && !state.later.contains(item.id)
        }
    }
}
