import Foundation
import Testing
@testable import SbuScanner

struct ResultActionTests {
    @Test func linkOpensAndCanBeCopied() {
        let url = URL(string: "https://sbu.dev")!
        let content = CodeContent.link(url)
        #expect(ResultAction.primary(for: content, raw: "https://sbu.dev") == .open(url))
        #expect(ResultAction.secondary(for: content, raw: "https://sbu.dev") == [.copy("https://sbu.dev")])
    }

    @Test func textIsCopiedFirstAndCanBeSearched() {
        let content = CodeContent.text("pasta al pomodoro")
        #expect(ResultAction.primary(for: content, raw: "pasta al pomodoro") == .copy("pasta al pomodoro"))
        #expect(ResultAction.secondary(for: content, raw: "pasta al pomodoro") == [.searchWeb("pasta al pomodoro")])
    }

    @Test func productIsSearchedOnTheWeb() {
        #expect(ResultAction.primary(for: .product("4006381333931"), raw: "4006381333931") == .searchWeb("4006381333931"))
    }

    @Test func wifiJoinsAndOffersThePassword() {
        let network = WiFiNetwork(ssid: "Casa", password: "pw")
        let content = CodeContent.wifi(network)
        #expect(ResultAction.primary(for: content, raw: network.code) == .joinWiFi(network))
        #expect(ResultAction.secondary(for: content, raw: network.code) == [.copyPassword("pw"), .copy(network.code)])
    }

    @Test func phoneCallsWithDigitsOnly() {
        #expect(ResultAction.primary(for: .phone("+39 02 1234"), raw: "tel:+39 02 1234") == .open(URL(string: "tel:+39021234")!))
    }

    @Test func searchURLIsSafariSearch() {
        #expect(ResultAction.searchURL("pasta & fagioli")?.absoluteString == "x-web-search://?pasta%20%26%20fagioli")
    }
}
