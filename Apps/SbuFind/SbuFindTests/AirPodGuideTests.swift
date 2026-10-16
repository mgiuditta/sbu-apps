import Foundation
import Testing
@testable import SbuFind

struct AirPodGuideTests {
    @Test func stepsAreNumberedInOrderWithoutGaps() {
        #expect(AirPodGuide.steps.map(\.id) == Array(1...AirPodGuide.steps.count))
    }

    @Test func everyStepHasTextAndASymbol() {
        for step in AirPodGuide.steps {
            #expect(!String(localized: step.text).isEmpty)
            #expect(!step.systemImage.isEmpty)
        }
    }

    /// The order the reviews ask for: case closed first, the case far away, then search, then Find My.
    @Test func theCaseGoesAwayBeforeTheSearchAndFindMyComesLast() {
        let symbols = AirPodGuide.steps.map(\.systemImage)
        #expect(symbols.first == "airpods.chargingcase")
        #expect(symbols.last == "location")
        #expect((symbols.firstIndex(of: "figure.walk") ?? .max) < (symbols.firstIndex(of: "antenna.radiowaves.left.and.right") ?? .min))
    }

    @Test func theHelpLeadsToTheGuideFromTheSingleAirPodSection() {
        #expect(HelpSection.all.contains { $0.id == HelpSection.singleAirPodID })
    }
}
