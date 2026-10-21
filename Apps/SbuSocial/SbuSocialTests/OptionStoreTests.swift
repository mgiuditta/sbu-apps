import Foundation
import Testing
@testable import SbuSocial

struct OptionStoreTests {
    private func store() -> OptionStore {
        OptionStore(defaults: UserDefaults(suiteName: "OptionStoreTests-\(UUID())")!)
    }

    @Test func filtersStartAsInSocialLiteWithSearchOpen() throws {
        let options = store()
        let rules = options.rules(for: .instagram)
        #expect(rules.hiddenLabels.contains("Sponsorizzato"))
        #expect(rules.hiddenLabels.contains("Suggeriti per te"))
        #expect(!rules.blocks(path: "/explore/search/", from: "/"))
        #expect(rules.blocks(path: "/explore/", from: "/"))
    }

    @Test func switchingSearchOnBlocksIt() throws {
        let options = store()
        let search = try #require(Platform.instagram.rules.options.first { $0.id == "search" })
        options.set(search, on: .instagram, to: true)
        #expect(options.rules(for: .instagram).blocks(path: "/explore/search/", from: "/"))
    }

    @Test func youtubeOptionsReachItsScriptAsFlags() throws {
        let options = store()
        #expect(options.rules(for: .youtube).flags == ["ads": true, "background": true])
        let ads = try #require(Platform.youtube.rules.options.first { $0.id == "ads" })
        options.set(ads, on: .youtube, to: false)
        #expect(options.rules(for: .youtube).flags["ads"] == false)
        #expect(!options.rules(for: .youtube).css.contains("ytm-promoted-video-renderer"))
    }

    @Test func choicesSurviveARelaunch() throws {
        let defaults = UserDefaults(suiteName: "OptionStoreTests-\(UUID())")!
        let options = OptionStore(defaults: defaults)
        let sponsored = try #require(Platform.instagram.rules.options.first { $0.id == "sponsored" })
        options.set(sponsored, on: .instagram, to: false)
        options.launchPlatform = .youtube
        let relaunched = OptionStore(defaults: defaults)
        #expect(!relaunched.isOn(sponsored, on: .instagram))
        #expect(relaunched.launchPlatform == .youtube)
    }
}
