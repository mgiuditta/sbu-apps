import Testing
@testable import SbuChats

struct SearchQueryTests {
    @Test(arguments: [
        ("vino", "\"vino\"*"),
        ("vino pane", "\"vino\"* \"pane\"*"),
        ("vino OR pane", "(\"vino\"* OR \"pane\"*)"),
        ("vino AND pane", "\"vino\"* \"pane\"*"),
        ("\"solito posto\"", "\"solito posto\""),
        ("“solito posto” vino", "\"solito posto\" \"vino\"*"),
        ("\"aperta", "\"aperta\""),
        ("OR vino", "\"vino\"*"),
        ("vino OR", "\"vino\"*"),
        ("perché?", "\"perché\"*"),
        ("l'amore", "\"l'amore\"*"),
    ])
    func buildsTheMatchExpression(input: String, expected: String) {
        #expect(SearchQuery.match(for: input) == expected)
    }

    @Test(arguments: ["", "   ", "\"\"", "-", "OR", "?!"])
    func nothingToSearchIsNil(input: String) {
        #expect(SearchQuery.match(for: input) == nil)
    }
}
