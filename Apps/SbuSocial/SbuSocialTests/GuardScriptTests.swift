import JavaScriptCore
import Testing
@testable import SbuSocial

/// The injected scripts must parse, or the page runs without its guard and shows everything.
struct GuardScriptTests {
    @Test(arguments: Platform.allCases)
    func scriptsParse(platform: Platform) {
        let rules = platform.rules
        for source in [GuardScript.css(rules), GuardScript.guardSource(rules), rules.scriptSource].compactMap(\.self) {
            #expect(syntaxError(in: source) == nil)
        }
    }

    @Test func youtubeHasItsScript() {
        #expect(Platform.youtube.rules.scriptSource != nil)
    }

    @Test func cssWithQuotesStaysOneString() {
        var rules = PlatformRules()
        rules.css = "a[href='/reels/'] { content: \"x\" }\n"
        #expect(syntaxError(in: GuardScript.css(rules)) == nil)
    }

    @Test func trackerRulesAreValidJSON() throws {
        let data = Data(TrackerRules.json.utf8)
        let rules = try #require(try JSONSerialization.jsonObject(with: data) as? [[String: Any]])
        #expect(rules.count == TrackerRules.domains.count)
    }

    /// Compiles without running: `new Function` parses the body and throws on a syntax error.
    private func syntaxError(in source: String) -> String? {
        let context = JSContext()!
        context.setObject(source, forKeyedSubscript: "source" as NSString)
        context.evaluateScript("new Function(source)")
        return context.exception?.toString()
    }
}
