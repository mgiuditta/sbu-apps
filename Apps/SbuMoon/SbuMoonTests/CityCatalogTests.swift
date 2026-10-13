import Foundation
import Testing
@testable import SbuMoon

struct CityCatalogTests {
    private let italian = Locale(identifier: "it_IT")
    private let english = Locale(identifier: "en_US")

    @Test func theBundledListLoadsWithUniqueIDsAndValidCoordinates() {
        let cities = CityCatalog.all

        #expect(cities.count > 50)
        #expect(Set(cities.map(\.id)).count == cities.count)
        #expect(cities.allSatisfy { abs($0.latitude) <= 90 && abs($0.longitude) <= 180 })
    }

    @Test func namesFollowTheLanguage() throws {
        let rome = try #require(CityCatalog.city(id: "rome"))

        #expect(rome.name(locale: italian) == "Roma")
        #expect(rome.name(locale: english) == "Rome")
    }

    @Test(arguments: ["roma", "ROME", "zurig", "reykjavik"])
    func searchIgnoresCaseAccentsAndLanguage(query: String) {
        #expect(CityCatalog.cities(matching: query, locale: italian).isEmpty == false)
    }

    @Test func anEmptySearchListsEverythingByName() {
        let names = CityCatalog.cities(matching: " ", locale: italian).map { $0.name(locale: italian) }

        #expect(names.count == CityCatalog.all.count)
        #expect(names.first == "Amsterdam")
    }
}
