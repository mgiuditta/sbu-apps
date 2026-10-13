import Testing
@testable import SbuHabits

struct TemplateSearchTests {
    private func ids(_ query: String) -> [String] {
        TemplateSearch.filter(HabitTemplate.all, matching: query).map(\.id)
    }

    @Test(arguments: ["", " ", "  \n"])
    func aBlankQueryIsNoSearch(query: String) {
        #expect(ids(query).isEmpty)
        #expect(TemplateSearch.sections(of: HabitTemplate.all, matching: query).isEmpty)
    }

    @Test(arguments: [
        ("dolci", ["avoid.sweets"]),
        ("SWEETS", ["avoid.sweets"]),
        ("caffe", ["avoid.coffee"]),
        ("caffè", ["avoid.coffee"]),
        ("coffee", ["avoid.coffee"]),
        ("legg", ["general.read", "timed.read"]),
        ("read", ["general.read", "timed.read"]),
        ("nuoto", ["health.swim"]),
        ("all'aperto", ["health.daylight"]),
        ("swimming", ["health.swim"]),
        ("anelli", ["health.rings"]),
        ("niente telefono", ["avoid.phoneInBed"]),
        ("phone bed", ["avoid.phoneInBed"]),
        ("vitamine", ["eating.vitamins"]),
        ("strumento", ["timed.instrument"]),
    ])
    func findsByTitleOrKeywordInBothLanguagesAcrossTabs(query: String, expected: [String]) {
        #expect(ids(query) == expected)
    }

    @Test(arguments: ["olci", "zzzz", "dolci caffè", "sweetsx"])
    func wordsMustStartAWordOfTheTemplate(query: String) {
        #expect(ids(query).isEmpty)
    }

    @Test func sectionsFollowTheTabOrderAndSkipEmptyOnes() {
        let sections = TemplateSearch.sections(of: HabitTemplate.all, matching: "meditare")

        #expect(sections.map(\.category) == [.health, .timed])
        #expect(sections[1].templates.map(\.id) == ["timed.meditate"])
    }
}
