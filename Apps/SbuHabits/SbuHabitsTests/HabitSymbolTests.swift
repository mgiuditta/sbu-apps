import Testing
import UIKit
@testable import SbuHabits

struct HabitSymbolTests {
    @Test(arguments: HabitSymbol.all.map(\.id))
    func everySymbolExists(name: String) {
        #expect(UIImage(systemName: name) != nil)
    }

    @Test func symbolsAreUnique() {
        #expect(Set(HabitSymbol.all.map(\.id)).count == HabitSymbol.all.count)
    }
}
