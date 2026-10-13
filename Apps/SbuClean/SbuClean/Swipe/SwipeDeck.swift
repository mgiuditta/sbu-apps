/// A queue of cards being swiped: where the user is and what to undo.
nonisolated struct SwipeDeck: Equatable, Sendable {
    /// One step back: the card and the decision it had before the swipe.
    nonisolated struct Step: Equatable, Sendable {
        var id: String
        var previous: SwipeDecision?
    }

    /// The queue, fixed when the deck opens.
    let ids: [String]
    /// The index of the card on top; `ids.count` when the deck is done.
    private(set) var position = 0
    private(set) var history: [Step] = []

    init(ids: [String]) {
        self.ids = ids
    }

    /// The card on top; `nil` when done.
    var current: String? {
        position < ids.count ? ids[position] : nil
    }

    /// The card under the top one, loaded ahead.
    var next: String? {
        position + 1 < ids.count ? ids[position + 1] : nil
    }

    var isDone: Bool {
        position >= ids.count
    }

    /// 1-based number of the card on top, for "12 di 225".
    var number: Int {
        min(position + 1, ids.count)
    }

    var canUndo: Bool {
        !history.isEmpty
    }

    /// Moves past the top card, remembering what it was before so it can be undone.
    mutating func advance(previous: SwipeDecision?) {
        guard let current else { return }

        history.append(Step(id: current, previous: previous))
        position += 1
    }

    /// Goes back one card and returns the step to revert.
    mutating func undo() -> Step? {
        guard let step = history.popLast() else { return nil }

        position -= 1
        return step
    }
}
