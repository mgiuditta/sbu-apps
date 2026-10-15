import Foundation
import Testing
@testable import SbuChats

struct AppTests {
    @Test func bundleIdentifierFollowsTheSbuScheme() {
        #expect(Bundle.main.bundleIdentifier == "dev.sbu.chats")
    }

    @Test func declaresZipAndTextDocumentsWithoutClaimingThem() throws {
        let types = try #require(Bundle.main.object(forInfoDictionaryKey: "CFBundleDocumentTypes") as? [[String: Any]])
        let contentTypes = types.flatMap { $0["LSItemContentTypes"] as? [String] ?? [] }
        #expect(contentTypes.contains("public.zip-archive"))
        #expect(contentTypes.contains("public.plain-text"))
        #expect(types.allSatisfy { $0["LSHandlerRank"] as? String == "Alternate" })
    }
}
