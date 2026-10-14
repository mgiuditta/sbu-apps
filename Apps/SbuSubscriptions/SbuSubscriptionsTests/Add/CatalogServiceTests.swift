import Testing
@testable import SbuSubscriptions

struct CatalogServiceTests {
    @Test func bundledCatalogHasEveryServiceOfThePreviousVersion() {
        let services = CatalogService.bundled
        #expect(services.count == 149)
        #expect(Set(services.map(\.id)).count == services.count)
    }

    @Test(arguments: [("netfl", "netflix"), ("DISNEY", "disneyplus"), ("babbel", "babbel")])
    func searchIgnoresCase(query: String, expected: String) {
        #expect(CatalogService.matching(query).contains { $0.id == expected })
    }

    @Test func emptyQueryShowsEverything() {
        #expect(CatalogService.matching("  ").count == CatalogService.bundled.count)
    }
}
