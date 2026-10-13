import Foundation
import Testing
@testable import SbuHabits

struct HealthMeasureGroupTests {
    @Test func everyMeasureIsInExactlyOneGroup() {
        let listed = HealthMeasureGroup.allCases.flatMap(\.measures)

        #expect(listed.count == HealthMeasure.allCases.count)
        #expect(Set(listed) == Set(HealthMeasure.allCases))
    }

    @Test(arguments: HealthMeasureGroup.allCases)
    func everyGroupIsNamedInBothLanguages(group: HealthMeasureGroup) {
        var title = group.title
        title.locale = Locale(identifier: "it_IT")
        let italian = String(localized: title)
        title.locale = Locale(identifier: "en_US")

        #expect(group.measures.isEmpty == false)
        #expect(italian != String(localized: title), "\(italian) has no English")
    }
}
