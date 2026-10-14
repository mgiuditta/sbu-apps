import Foundation
import Testing
@testable import SbuScanner

struct CodeDraftTests {
    @Test func emptyDraftsHaveNoPayload() {
        for kind in CodeKind.allCases {
            #expect(CodeDraft(kind: kind).payload == nil, "\(kind)")
        }
    }

    @Test(arguments: [("sbu.dev", "https://sbu.dev"), ("http://example.com/x", "http://example.com/x"), (" sbu.dev/apps ", "https://sbu.dev/apps")])
    func linksGetAScheme(typed: String, expected: String) {
        var draft = CodeDraft(kind: .link)
        draft.link = typed
        #expect(draft.payload == expected)
    }

    @Test(arguments: ["sbu", "sbu dev.com", ""])
    func notALink(typed: String) {
        var draft = CodeDraft(kind: .link)
        draft.link = typed
        #expect(draft.payload == nil)
    }

    @Test func wifiPayloadReadsBackAsTheSameNetwork() throws {
        var draft = CodeDraft(kind: .wifi)
        draft.wifi = WiFiNetwork(ssid: "Ospiti", password: "benvenuti")
        let payload = try #require(draft.payload)
        #expect(CodeContent(payload, symbology: .qr) == .wifi(draft.wifi))
    }

    @Test func contactTakesThePhoneAndEmailFields() throws {
        var draft = CodeDraft(kind: .contact)
        draft.contact.name = "Anna Rossi"
        draft.contactPhone = "+39 333 1234567"
        draft.contactEmail = "anna@example.com"
        let payload = try #require(draft.payload)
        guard case let .contact(card) = CodeContent(payload, symbology: .qr) else {
            Issue.record("Not a contact: \(payload)")
            return
        }
        #expect(card.phones == ["+39 333 1234567"])
        #expect(card.emails == ["anna@example.com"])
    }

    @Test(arguments: [("+39 02 1234 5678", "tel:+390212345678"), ("1-2", nil), ("abc", nil)])
    func phone(typed: String, expected: String?) {
        var draft = CodeDraft(kind: .phone)
        draft.phone = typed
        #expect(draft.payload == expected)
    }

    @Test func locationTakesCommaDecimals() {
        var draft = CodeDraft(kind: .location)
        draft.latitude = "45,4642"
        draft.longitude = "9,19"
        #expect(draft.payload == "geo:45.4642,9.19")
        draft.latitude = "95"
        #expect(draft.payload == nil)
    }

    @Test func productNeedsAValidEAN13UnlessCode128() {
        var draft = CodeDraft(kind: .product)
        draft.productNumber = "400638133393"
        #expect(draft.payload == "4006381333931")
        draft.productNumber = "4006381333932"
        #expect(draft.payload == nil)
        draft.format = .code128
        #expect(draft.payload == "4006381333932")
    }

    @Test func eventEndingBeforeItStartsIsRefused() {
        var draft = CodeDraft(kind: .event, start: Date(timeIntervalSince1970: 1_792_522_800))
        draft.event.title = "Cena"
        #expect(draft.payload != nil)
        draft.event.end = draft.event.start.addingTimeInterval(-60)
        #expect(draft.payload == nil)
    }

    @Test func eventStartsOnTheNextHour() {
        let draft = CodeDraft(kind: .event, start: Date(timeIntervalSince1970: 1_792_522_800 + 1_234))
        #expect(Calendar.current.component(.minute, from: draft.event.start) == 0)
        #expect(draft.event.start > Date(timeIntervalSince1970: 1_792_522_800 + 1_234))
    }

    @Test func formatsByKind() {
        #expect(CodeDraft(kind: .product).formats.first == .ean13)
        #expect(CodeDraft(kind: .product).format == .ean13)
        #expect(!CodeDraft(kind: .product).formats.contains(.qr))
        #expect(CodeDraft(kind: .text).formats.first == .qr)
        #expect(CodeDraft(kind: .wifi).formats == [.qr, .aztec, .pdf417])
    }

    @Test func code39IsSavedInCapitals() {
        var draft = CodeDraft(kind: .text)
        draft.text = "sbu-42"
        draft.format = .code39
        #expect(draft.payload == "SBU-42")
        draft.text = "sbu_42"
        #expect(draft.payload == nil)
    }
}
