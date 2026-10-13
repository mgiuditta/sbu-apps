import Testing
@testable import SbuHabits

struct SymbolSearchTests {
    private static let symbols = [
        HabitSymbol("drop", "Acqua", "Water", .health, "bere idratazione drink"),
        HabitSymbol("figure.run", "Corsa", "Run", .sport, "correre jogging"),
        HabitSymbol("figure.archery", "Tiro con l'arco", "Archery", .sport, "frecce arrows"),
        HabitSymbol("mug", "Caffè", "Coffee", .food, "tazza tè tea"),
        HabitSymbol("aqi.medium", "Qualità dell'aria", "Air quality", .nature, "inquinamento pollution"),
    ]

    private func ids(_ query: String) -> [String] {
        SymbolSearch.filter(Self.symbols, matching: query).map(\.id)
    }

    @Test(arguments: ["", " ", "  \n"])
    func aBlankQueryShowsEverything(query: String) {
        #expect(ids(query) == Self.symbols.map(\.id))
    }

    @Test(arguments: [
        ("acqua", ["drop"]),
        ("water", ["drop"]),
        ("ACQUA", ["drop"]),
        ("Drink", ["drop"]),
        ("corr", ["figure.run"]),
        ("jog", ["figure.run"]),
        ("caffe", ["mug"]),
        ("caffè", ["mug"]),
        ("te", ["mug"]),
        ("arco", ["figure.archery"]),
        ("l'arco", ["figure.archery"]),
        ("qualita aria", ["aqi.medium"]),
        ("air quality", ["aqi.medium"]),
        ("frecce", ["figure.archery"]),
    ])
    func findsByNameOrKeywordInBothLanguages(query: String, expected: [String]) {
        #expect(ids(query) == expected)
    }

    @Test(arguments: ["ua", "zzz", "acqua corsa", "runner"])
    func wordsMustStartAWordOfTheSymbol(query: String) {
        #expect(ids(query).isEmpty)
    }

    @Test func sectionsFollowTheCategoryOrderAndSkipEmptyOnes() {
        let sections = SymbolSearch.sections(of: Self.symbols, matching: "a")
        #expect(sections.map(\.category) == [.health, .sport, .nature])
        #expect(sections[1].symbols.map(\.id) == ["figure.archery"])
    }

    @Test func noMatchMeansNoSections() {
        #expect(SymbolSearch.sections(of: Self.symbols, matching: "xyz").isEmpty)
    }

    @Test func theCatalogFindsWaterInEnglish() {
        let found = SymbolSearch.filter(HabitSymbol.all, matching: "water").map(\.id)
        #expect(found.contains("drop"))
    }
}
