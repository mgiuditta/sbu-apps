import Foundation

/// Everything the home and the timeline show about the library, worked out in one pass off the
/// main actor, so a library of tens of thousands of items never slows the screen down.
nonisolated struct LibrarySummary: Equatable, Sendable {
    nonisolated struct Category: Equatable, Sendable {
        var count = 0
        var bytes: Int64 = 0
    }

    var itemCount = 0
    var freeableBytes: Int64 = 0
    var selectedGroupBytes: Int64 = 0
    var groupCount = 0
    var screenshots = Category()
    var screenRecordings = Category()
    var videos = Category()
    /// The Live Photos, with the bytes of their video parts.
    var livePhotos = Category()
    /// Months newest first, with how many items are decided.
    var months: [MonthProgress] = []
    var recentCount = 0
    var onThisDayCount = 0

    /// Works the summary out.
    /// - Parameters:
    ///   - items: The library, newest first.
    ///   - monthOf: The month of each item, worked out once when the library is read.
    ///   - state: The decisions.
    ///   - groups: Duplicate and similar groups.
    ///   - selection: The group members going to the bin.
    ///   - now: Today, for Recenti and Accadde oggi.
    ///   - calendar: The calendar of the months.
    init(items: [MediaItem], monthOf: [String: YearMonth], state: CleanState, groups: [PhotoGroup], selection: GroupSelection, now: Date, calendar: Calendar = .current) {
        itemCount = items.count
        let trash = Set(state.trash)
        let selected = selection.selected(in: groups)
        groupCount = groups.count
        let recentStart = calendar.date(byAdding: .day, value: -QueueBuilder.recentDays, to: now) ?? now
        let today = calendar.dateComponents([.year, .month, .day], from: now)
        let todayStart = calendar.startOfDay(for: now)

        var freeable = Set(state.trash)
        freeable.formUnion(selected)
        var byID: [String: Int64] = [:]
        byID.reserveCapacity(items.count)
        var progress: [YearMonth: MonthProgress] = [:]

        for item in items {
            byID[item.id] = item.bytes
            let isKeptForever = state.keepForever.contains(item.id)
            let isOpen = !isKeptForever && !trash.contains(item.id) && !state.kept.contains(item.id) && !state.later.contains(item.id)

            if !isKeptForever {
                if item.isScreenshot {
                    screenshots.count += 1
                    screenshots.bytes += item.bytes
                    freeable.insert(item.id)
                }
                if item.isScreenRecording {
                    screenRecordings.count += 1
                    screenRecordings.bytes += item.bytes
                    freeable.insert(item.id)
                }
                if item.kind == .video {
                    videos.count += 1
                    videos.bytes += item.bytes
                }
                if item.isLivePhoto {
                    livePhotos.count += 1
                    livePhotos.bytes += item.size?.pairedVideoBytes ?? 0
                }
            }

            if let month = monthOf[item.id] {
                progress[month, default: MonthProgress(month: month, total: 0, decided: 0)].total += 1
                if !isOpen {
                    progress[month]?.decided += 1
                }
            }

            guard isOpen, let date = item.creationDate else { continue }

            if date >= recentStart {
                recentCount += 1
            }
            // Accadde oggi: same day and month, an earlier year. The month is known already, so
            // the calendar only runs for this month's items.
            if date < todayStart, let month = monthOf[item.id], month.month == today.month, month.year != today.year,
               calendar.component(.day, from: date) == today.day {
                onThisDayCount += 1
            }
        }

        freeable.subtract(state.keepForever)
        freeableBytes = freeable.reduce(0) { $0 + (byID[$1] ?? 0) }
        selectedGroupBytes = selected.reduce(0) { $0 + (byID[$1] ?? 0) }
        months = progress.values.sorted { $0.month > $1.month }
    }

    init() {}
}
