import Foundation
import Testing
@testable import SbuScanner

struct MessageTests {
    @Test func mailtoWithSubjectAndBody() throws {
        let email = try #require(EmailMessage(code: "mailto:anna@example.com?subject=Ciao%20Anna&body=A%20presto"))
        #expect(email == EmailMessage(address: "anna@example.com", subject: "Ciao Anna", body: "A presto"))
    }

    @Test func matmsgAndSMTP() throws {
        #expect(try #require(EmailMessage(code: "MATMSG:TO:a@example.com;SUB:Ciao;BODY:Testo;;")) == EmailMessage(address: "a@example.com", subject: "Ciao", body: "Testo"))
        #expect(try #require(EmailMessage(code: "SMTP:a@example.com:Ciao:Testo: con due punti")) == EmailMessage(address: "a@example.com", subject: "Ciao", body: "Testo: con due punti"))
    }

    @Test func emailRoundTrip() throws {
        let email = EmailMessage(address: "a@example.com", subject: "Ciao & benvenuto", body: "Riga uno\nRiga due")
        #expect(EmailMessage(code: email.code) == email)
    }

    @Test(arguments: [
        ("SMSTO:+39333:Ciao: a presto", TextMessage(number: "+39333", body: "Ciao: a presto")),
        ("sms:+39333?body=Ciao%20Anna", TextMessage(number: "+39333", body: "Ciao Anna")),
        ("sms:+39333:Ciao", TextMessage(number: "+39333", body: "Ciao")),
        ("SMS:+39333", TextMessage(number: "+39333")),
    ])
    func textMessages(code: String, expected: TextMessage) {
        #expect(TextMessage(code: code) == expected)
    }

    @Test func textMessageURLCarriesTheBody() throws {
        let url = try #require(TextMessage(number: "+39333", body: "Ciao Anna").url)
        #expect(url.absoluteString == "sms:+39333?body=Ciao%20Anna")
    }

    @Test(arguments: [("geo:45.4642,9.19", 45.4642, 9.19), ("GEO:-33.86,151.2,50?q=Opera", -33.86, 151.2)])
    func geo(code: String, latitude: Double, longitude: Double) throws {
        let point = try #require(GeoPoint(code: code))
        #expect(point.latitude == latitude)
        #expect(point.longitude == longitude)
    }

    @Test(arguments: ["geo:91,0", "geo:0,181", "geo:abc", "geo:45"])
    func geoOutOfRangeOrBroken(code: String) {
        #expect(GeoPoint(code: code) == nil)
    }
}
