import Foundation
import Testing
@testable import SbuInventory

struct SearchTests {
    @Test func keyFoldsCaseAccentsAndSpaces() {
        #expect(SearchKey.make(["Caffè  Moka", "", "NOTE"]) == "caffe moka note")
    }

    @Test(arguments: [
        ("trapano", true),
        ("TRAPANO garage", true),
        ("garage trapano", true),
        ("perçeuse", false),
        ("caffe", false),
        ("", true),
    ])
    func everyWordMustBeInTheKey(text: String, matches: Bool) {
        let key = SearchKey.make(["Trapano", "in garage", "attrezzi"])
        #expect(SearchQuery(text).matches(key) == matches)
    }

    @Test func accentsInTheQueryAreIgnored() {
        #expect(SearchQuery("caffè").matches(SearchKey.make(["Capsule di caffe"])))
    }

    @Test func filterNarrowsByTagLowAndFolder() {
        let inside = UUID(), outside = UUID()
        var filter = ItemFilter()
        filter.tags = ["Attrezzi"]
        #expect(filter.isActive)
        #expect(filter.matches(key: "trapano", tags: ["attrezzi"], isLow: false, folderID: nil))
        #expect(!filter.matches(key: "trapano", tags: [], isLow: false, folderID: nil))

        filter = ItemFilter(onlyLow: true)
        #expect(filter.matches(key: "pile", tags: [], isLow: true, folderID: nil))
        #expect(!filter.matches(key: "pile", tags: [], isLow: false, folderID: nil))

        filter = ItemFilter(query: SearchQuery("pile"), folders: [inside])
        #expect(filter.matches(key: "pile aa", tags: [], isLow: false, folderID: inside))
        #expect(!filter.matches(key: "pile aa", tags: [], isLow: false, folderID: outside))
        #expect(!filter.matches(key: "pile aa", tags: [], isLow: false, folderID: nil))
    }

    @Test func emptyFilterIsNotActive() {
        #expect(!ItemFilter().isActive)
        #expect(!ItemFilter(query: SearchQuery("   ")).isActive)
    }

    @Test func tagsAreTrimmedAndKeptOnce() {
        #expect(TagList.normalized([" Attrezzi ", "attrezzi", "", "Àttrezzi", "Garage"]) == ["Attrezzi", "Garage"])
    }

    @Test func tagSuggestionsStartWithWhatYouTypeAndSkipTheItemsOwn() {
        let all = ["attrezzi", "Garage", "giardino", "Cucina"]
        #expect(TagList.suggestions(for: "g", among: all, excluding: ["garage"]) == ["giardino"])
        #expect(TagList.suggestions(for: "", among: all, excluding: []) == ["attrezzi", "Cucina", "Garage", "giardino"])
    }
}
