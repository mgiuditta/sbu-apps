import Testing
@testable import SbuGrid

struct HelpStepTests {
    @Test func fourStepsInTheOrderYouDraw() {
        #expect(HelpStep.all.map(\.id) == [1, 2, 3, 4])
        #expect(HelpStep.all.first?.systemImage == "photo")
        #expect(HelpStep.all.last?.systemImage == "camera.viewfinder")
    }

    @Test func everyStepHasItsOwnSymbol() {
        #expect(Set(HelpStep.all.map(\.systemImage)).count == HelpStep.all.count)
        #expect(Set(HelpStep.all.map(\.text.key)).count == HelpStep.all.count)
    }
}
