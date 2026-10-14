import Testing
@testable import SbuScanner

struct WiFiNetworkTests {
    @Test func readsAllFields() throws {
        let network = try #require(WiFiNetwork(code: "WIFI:T:WPA;S:Casa Rossi;P:girasole;H:true;;"))
        #expect(network == WiFiNetwork(ssid: "Casa Rossi", password: "girasole", security: .wpa, isHidden: true))
    }

    @Test func fieldsInAnyOrderAndLowercasePrefix() throws {
        let network = try #require(WiFiNetwork(code: "wifi:P:pw;S:Rete;T:WEP;;"))
        #expect(network.ssid == "Rete")
        #expect(network.security == .wep)
        #expect(network.password == "pw")
    }

    @Test func escapedSeparatorsStayInTheValues() throws {
        let network = try #require(WiFiNetwork(code: #"WIFI:S:Bar\;Caffè;T:WPA;P:a\:b\\c\,d;;"#))
        #expect(network.ssid == "Bar;Caffè")
        #expect(network.password == #"a:b\c,d"#)
    }

    @Test(arguments: [("nopass", WiFiNetwork.Security.open), ("WPA2", .wpa), ("SAE", .wpa), ("", .open)])
    func security(type: String, expected: WiFiNetwork.Security) throws {
        let network = try #require(WiFiNetwork(code: "WIFI:S:Rete;T:\(type);;"))
        #expect(network.security == expected)
    }

    @Test func missingTypeWithPasswordIsWPA() throws {
        #expect(try #require(WiFiNetwork(code: "WIFI:S:Rete;P:pw;;")).security == .wpa)
    }

    @Test func noNameIsNotANetwork() {
        #expect(WiFiNetwork(code: "WIFI:T:WPA;P:pw;;") == nil)
    }

    @Test(arguments: [
        WiFiNetwork(ssid: "Casa", password: "pw", security: .wpa),
        WiFiNetwork(ssid: "Bar;Caffè: \"centro\"", password: #"a\b,c"#, security: .wep, isHidden: true),
        WiFiNetwork(ssid: "Ospiti", security: .open),
    ])
    func roundTrip(network: WiFiNetwork) {
        #expect(WiFiNetwork(code: network.code) == network)
    }
}
