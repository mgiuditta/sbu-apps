import Testing
@testable import SbuClean

struct SwipeDeckTests {
    @Test func advancesThroughTheQueue() {
        var deck = SwipeDeck(ids: ["a", "b"])
        #expect(deck.current == "a")
        #expect(deck.next == "b")
        #expect(deck.number == 1)

        deck.advance(previous: nil)
        #expect(deck.current == "b")
        #expect(deck.next == nil)

        deck.advance(previous: nil)
        #expect(deck.isDone)
        #expect(deck.current == nil)
        #expect(deck.number == 2)
    }

    @Test func undoGoesBackWithThePreviousDecision() {
        var deck = SwipeDeck(ids: ["a", "b", "c"])
        deck.advance(previous: nil)
        deck.advance(previous: .later)

        let step = deck.undo()

        #expect(step == SwipeDeck.Step(id: "b", previous: .later))
        #expect(deck.current == "b")
        #expect(deck.canUndo)
        _ = deck.undo()
        #expect(!deck.canUndo)
        #expect(deck.undo() == nil)
        #expect(deck.current == "a")
    }

    @Test func anEmptyDeckIsDone() {
        let deck = SwipeDeck(ids: [])
        #expect(deck.isDone)
        #expect(deck.number == 0)
    }
}
