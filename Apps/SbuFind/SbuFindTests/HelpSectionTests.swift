import Foundation
import Testing
@testable import SbuFind

struct HelpSectionTests {
    @Test func findMyOpensApplesApp() {
        #expect(HelpSection.findMyURL?.scheme == "findmy")
    }

    @Test func sectionsAndItemsHaveDistinctIdentifiers() {
        let sections = HelpSection.all
        #expect(Set(sections.map(\.id)).count == sections.count)
        for section in sections {
            #expect(!section.items.isEmpty)
            #expect(Set(section.items.map(\.id)).count == section.items.count)
        }
    }

    @Test func everySentenceHasASymbolAndText() {
        for item in HelpSection.all.flatMap(\.items) {
            #expect(!item.systemImage.isEmpty)
            #expect(!String(localized: item.text).isEmpty)
        }
    }

    /// The four things the map asks the help to say: how to search, what it cannot hear,
    /// a single AirPod, and Find My for Apple products.
    @Test func coversTheFourTopics() {
        #expect(HelpSection.all.count == 4)
        let symbols = Set(HelpSection.all.flatMap(\.items).map(\.systemImage))
        #expect(symbols.isSuperset(of: ["airpods.chargingcase", "battery.0percent", "airpod.right", "location"]))
    }
}
