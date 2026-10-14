import Foundation
import Testing
@testable import SbuScanner

struct CodeContentTests {
    @Test(arguments: [
        ("https://sbu.dev/apps", CodeKind.link),
        ("http://example.com", .link),
        ("www.example.com/menu", .link),
        ("WIFI:S:Casa;T:WPA;P:pw;;", .wifi),
        ("BEGIN:VCARD\nVERSION:3.0\nFN:Anna Rossi\nEND:VCARD", .contact),
        ("MECARD:N:Rossi,Anna;TEL:333;;", .contact),
        ("mailto:anna@example.com?subject=Ciao", .email),
        ("MATMSG:TO:anna@example.com;SUB:Ciao;BODY:Testo;;", .email),
        ("tel:+390212345678", .phone),
        ("SMSTO:+39333:Ciao", .textMessage),
        ("sms:+39333?body=Ciao", .textMessage),
        ("geo:45.4642,9.19", .location),
        ("BEGIN:VEVENT\nSUMMARY:Cena\nDTSTART:20261020T190000Z\nEND:VEVENT", .event),
        ("Ciao, come stai?", .text),
        ("ftp://example.com", .text),
        ("example .com", .text),
    ])
    func kindFromQR(raw: String, kind: CodeKind) {
        #expect(CodeContent(raw, symbology: .qr).kind == kind)
    }

    @Test func productBarcodeIsAlwaysAProductEvenIfItLooksLikeText() {
        #expect(CodeContent("4006381333931", symbology: .ean13) == .product("4006381333931"))
        #expect(CodeContent("0036000291452", symbology: .upce).kind == .product)
    }

    @Test func code128WithALinkIsALink() {
        #expect(CodeContent("https://sbu.dev", symbology: .code128).kind == .link)
    }

    @Test func surroundingWhitespaceIsIgnored() {
        #expect(CodeContent("  https://sbu.dev\n", symbology: .qr) == .link(URL(string: "https://sbu.dev")!))
    }

    @Test func wwwGetsHTTPS() {
        #expect(CodeContent("www.example.com", symbology: .qr) == .link(URL(string: "https://www.example.com")!))
    }

    @Test func emptyTelIsText() {
        #expect(CodeContent("tel:", symbology: .qr) == .text("tel:"))
    }

    @Test(arguments: [
        ("https://sbu.dev/apps/scanner", "sbu.dev/apps/scanner"),
        ("https://sbu.dev/", "sbu.dev"),
        ("Prima riga\nSeconda", "Prima riga"),
        ("WIFI:S:Casa;;", "Casa"),
    ])
    func summary(raw: String, expected: String) {
        #expect(CodeContent(raw, symbology: .qr).summary == expected)
    }
}
