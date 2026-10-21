import Foundation
import Testing
@testable import SbuSocial

struct PlatformRulesTests {
    private let instagram = Platform.instagram.rules

    @Test func everyPlatformHasRulesInTheBundle() {
        for platform in Platform.allCases {
            #expect(PlatformRules.all[platform] != nil, "\(platform) has no rules")
        }
    }

    @Test(arguments: [
        ("www.instagram.com", true), ("instagram.com", true), ("scontent.cdninstagram.com", false),
        ("notinstagram.com", false), ("example.com", false),
    ])
    func instagramLoadsOnlyItsHosts(host: String, allowed: Bool) {
        #expect(instagram.allows(host: host) == allowed)
    }

    @Test(arguments: [
        ("/reels/", "/", true),
        ("/explore/", "/direct/inbox/", true),
        ("/reel/abc/", "/direct/t/123/", false),
        ("/reel/def/", "/reel/abc/", true),
        ("/reel/abc/", "/reel/abc/", false),
        ("/direct/inbox/", "/reel/abc/", false),
        ("/stories/someone/", "/", false),
    ])
    func instagramBlocksReelsExploreAndTheNextVideo(path: String, current: String, blocked: Bool) {
        #expect(instagram.blocks(path: path, from: current) == blocked)
    }

    @Test func instagramHomeOpensTheFeedOfThePeopleYouFollow() throws {
        let home = try #require(URL(string: "https://www.instagram.com/"))
        #expect(instagram.redirect(home)?.absoluteString == "https://www.instagram.com/?variant=following")
        let following = try #require(URL(string: "https://www.instagram.com/?variant=following"))
        #expect(instagram.redirect(following) == nil)
    }
}

struct YouTubeRulesTests {
    private let youtube = Platform.youtube.rules

    @Test(arguments: [
        ("https://m.youtube.com/shorts/abc123", "https://m.youtube.com/watch?v=abc123"),
        ("https://m.youtube.com/shorts/xyz?feature=share", "https://m.youtube.com/watch?v=xyz"),
    ])
    func shortsOpenAsVideos(from: String, to: String) throws {
        let url = try #require(URL(string: from))
        #expect(youtube.redirect(url)?.absoluteString == to)
    }

    @Test func aVideoStaysWhereItIs() throws {
        let url = try #require(URL(string: "https://m.youtube.com/watch?v=abc123"))
        #expect(youtube.redirect(url) == nil)
    }

    @Test(arguments: [("/feed/trending", true), ("/feed/subscriptions", false), ("/results", false)])
    func trendingIsClosed(path: String, blocked: Bool) {
        #expect(youtube.blocks(path: path, from: "/") == blocked)
    }

    @Test(arguments: [("m.youtube.com", true), ("accounts.google.com", true), ("www.google.com", false), ("i.ytimg.com", false)])
    func pagesOpenOnlyOnYouTubeAndGoogleSignIn(host: String, allowed: Bool) {
        #expect(youtube.allows(host: host) == allowed)
    }
}
