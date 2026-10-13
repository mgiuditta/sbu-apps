/// Where a swipe queue comes from.
nonisolated enum SwipeSource: Hashable, Sendable {
    /// The last 30 days, newest first.
    case recent
    /// A shuffled handful from the whole library.
    case random
    /// Taken on this day in past years.
    case onThisDay
    /// The items set aside to decide later.
    case later
    /// One month, oldest first.
    case month(YearMonth)
    /// One of the user's albums.
    case album(Album)
    /// One category, such as screenshots, biggest first.
    case category(MediaCategory)
}
