/// What the user decided about one item.
nonisolated enum SwipeDecision: String, Codable, Sendable {
    /// Swiped right: stays in the library and leaves the queue.
    case keep
    /// Swiped left: waits in the bin for the final review.
    case trash
    /// Set aside for later, in its own queue.
    case later
    /// Never proposed again, in any queue or category.
    case keepForever
}
