import Testing
@testable import SbuScanner

struct ContactCardTests {
    @Test func readsAVCardWithParametersGroupsAndFolding() throws {
        let vCard = """
        BEGIN:VCARD\r
        VERSION:3.0\r
        N:Bianchi;Giulia;;;\r
        FN:Giulia Bianchi\r
        ORG:Studio Bianchi;Design\r
        TEL;TYPE=CELL:+39 333 1234567\r
        item1.EMAIL;TYPE=INTERNET:giulia@exam\r
         ple.com\r
        ADR;TYPE=WORK:;;Via Roma 1;Milano;;20100;Italia\r
        URL:https://example.com\r
        END:VCARD
        """
        let card = try #require(ContactCard(code: vCard))
        #expect(card.name == "Giulia Bianchi")
        #expect(card.organization == "Studio Bianchi Design")
        #expect(card.phones == ["+39 333 1234567"])
        #expect(card.emails == ["giulia@example.com"])
        #expect(card.address == "Via Roma 1, Milano, 20100, Italia")
        #expect(card.website == "https://example.com")
    }

    @Test func nameFromNWhenThereIsNoFN() throws {
        let card = try #require(ContactCard(code: "BEGIN:VCARD\nN:Rossi;Anna;;;\nEND:VCARD"))
        #expect(card.name == "Anna Rossi")
    }

    @Test func readsAMECARD() throws {
        let card = try #require(ContactCard(code: "MECARD:N:Rossi,Anna;TEL:3331234567;EMAIL:anna@example.com;;"))
        #expect(card.name == "Anna Rossi")
        #expect(card.phones == ["3331234567"])
        #expect(card.emails == ["anna@example.com"])
    }

    @Test func emptyCardIsNotAContact() {
        #expect(ContactCard(code: "BEGIN:VCARD\nVERSION:3.0\nEND:VCARD") == nil)
    }

    @Test func roundTripThroughVCard() throws {
        let card = ContactCard(name: "Anna Maria Rossi", organization: "Rossi, Srl", phones: ["+39 02 1234"], emails: ["a@example.com"], website: "https://example.com", address: "Via Po 2, Torino")
        let read = try #require(ContactCard(code: card.vCard))
        #expect(read.name == card.name)
        #expect(read.organization == card.organization)
        #expect(read.phones == card.phones)
        #expect(read.emails == card.emails)
        #expect(read.website == card.website)
        #expect(read.address == card.address)
    }
}
