import Foundation
import Testing
import UIKit
@testable import SbuHabits

struct HabitSymbolTests {
    /// The symbols of the first catalog: saved habits use them, so they must stay.
    nonisolated static let firstCatalog = [
        "drop", "cup.and.saucer", "fork.knife", "carrot", "pills", "bed.double", "moon", "sun.max", "alarm",
        "figure.walk", "figure.run", "bicycle", "figure.pool.swim", "dumbbell", "figure.yoga", "figure.mind.and.body",
        "lungs", "heart", "brain.head.profile", "book", "books.vertical", "pencil", "graduationcap",
        "character.book.closed", "music.note", "guitars", "paintbrush", "camera", "leaf", "tree", "pawprint", "house",
        "shower", "washer", "cart", "banknote", "phone", "iphone.slash", "envelope", "person.2", "checklist", "clock",
    ]

    @Test(arguments: HabitSymbol.all.map(\.id))
    func everySymbolExists(name: String) {
        #expect(UIImage(systemName: name) != nil)
    }

    @Test func symbolsAreUnique() {
        #expect(Set(HabitSymbol.all.map(\.id)).count == HabitSymbol.all.count)
    }

    @Test func namesAreUnique() {
        #expect(Set(HabitSymbol.all.map(\.name.key)).count == HabitSymbol.all.count)
    }

    @Test func thereAreHundreds() {
        #expect(HabitSymbol.all.count >= 300)
    }

    @Test(arguments: firstCatalog)
    func savedSymbolsStay(id: String) {
        #expect(HabitSymbol.named(id) != nil)
    }

    @Test func newHabitsStillStartWithWater() {
        #expect(HabitSymbol.all.first?.id == "drop")
    }

    @Test(arguments: HabitSymbolCategory.allCases)
    func everyCategoryHasSymbols(category: HabitSymbolCategory) {
        #expect(HabitSymbol.all.contains { $0.category == category })
    }

    @Test func anUnknownNameIsNotInTheCatalog() {
        #expect(HabitSymbol.named("not.a.symbol") == nil)
    }

    @Test func namesAreTranslated() {
        let english = HabitSymbol.all.filter { symbol in
            var name = symbol.name
            name.locale = Locale(identifier: "en")
            return String(localized: name) != symbol.name.key
        }
        // A few names are the same in both languages.
        #expect(english.count > HabitSymbol.all.count * 3 / 4)
    }
}
