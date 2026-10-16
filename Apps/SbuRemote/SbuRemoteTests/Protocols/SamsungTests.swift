import Foundation
import Testing
@testable import SbuRemote

struct SamsungTests {
    @Test func secureURLCarriesNameAndToken() throws {
        let url = try #require(SamsungMessage.remoteURL(host: "192.168.1.20", transport: .secure, token: "12345678"))
        #expect(url.absoluteString == "wss://192.168.1.20:8002/api/v2/channels/samsung.remote.control?name=U2J1IFJlbW90ZQ==&token=12345678")
    }

    @Test func plainURLNeverCarriesTheToken() throws {
        let url = try #require(SamsungMessage.remoteURL(host: "10.0.0.4", transport: .plain, token: "12345678"))
        #expect(url.absoluteString == "ws://10.0.0.4:8001/api/v2/channels/samsung.remote.control?name=U2J1IFJlbW90ZQ==")
    }

    @Test(arguments: [
        (KeyAction.click, "Click"),
        (.press, "Press"),
        (.release, "Release"),
    ])
    func keyCommand(action: KeyAction, command: String) {
        #expect(SamsungMessage.key("KEY_VOLUP", action: action) ==
            #"{"method":"ms.remote.control","params":{"Cmd":"\#(command)","DataOfCmd":"KEY_VOLUP","Option":"false","TypeOfRemote":"SendRemoteKey"}}"#)
    }

    @Test(arguments: [
        (RemoteKey.back, "KEY_RETURN"),
        (.select, "KEY_ENTER"),
        (.source, "KEY_SOURCE"),
        (.channelDown, "KEY_CHDOWN"),
    ])
    func keyCodes(key: RemoteKey, code: String) {
        #expect(SamsungMessage.keyCode(for: key) == code)
    }

    @Test func replayHasNoSamsungCode() {
        #expect(SamsungMessage.keyCode(for: .replay) == nil)
    }

    @Test func textGoesAsBase64() {
        #expect(SamsungMessage.text("ciao") ==
            #"{"method":"ms.remote.control","params":{"Cmd":"Y2lhbw==","DataOfCmd":"base64","TypeOfRemote":"SendInputString"}}"#)
    }

    @Test(arguments: [(2, "DEEP_LINK"), (4, "NATIVE_LAUNCH")])
    func launchActionDependsOnAppType(type: Int, action: String) {
        #expect(SamsungMessage.launch(appID: "111299001912", appType: type) ==
            #"{"method":"ms.channel.emit","params":{"data":{"action_type":"\#(action)","appId":"111299001912"},"event":"ed.apps.launch","to":"host"}}"#)
    }

    @Test func connectEventCarriesTheToken() {
        let text = #"{"event":"ms.channel.connect","data":{"id":"abc","token":"18527311","clients":[]}}"#
        #expect(SamsungEvent(text) == .connected(token: "18527311"))
    }

    @Test func numericTokenBecomesText() {
        #expect(SamsungEvent(#"{"event":"ms.channel.connect","data":{"token":18527311}}"#) == .connected(token: "18527311"))
    }

    @Test func deniedAndTimeout() {
        #expect(SamsungEvent(#"{"event":"ms.channel.unauthorized"}"#) == .unauthorized)
        #expect(SamsungEvent(#"{"event":"ms.channel.timeOut"}"#) == .timedOut)
        #expect(SamsungEvent("not json") == .other)
    }

    @Test func installedApps() {
        let text = #"{"event":"ed.installedApp.get","data":{"data":[{"appId":"111299001912","app_type":2,"name":"YouTube"},{"appId":"3201907018807","app_type":4,"name":"Netflix"},{"name":"broken"}]}}"#
        #expect(SamsungEvent(text) == .installedApps([
            .init(id: "111299001912", name: "YouTube", type: 2),
            .init(id: "3201907018807", name: "Netflix", type: 4),
        ]))
    }

    @Test func deviceInfo() throws {
        let json = #"{"device":{"name":"%5BTV%5D%20Soggiorno","modelName":"QE55Q80TATXZT","wifiMac":"a0:b1:c2:d3:e4:f5","TokenAuthSupport":"true"},"name":"[TV] Soggiorno"}"#
        let info = try #require(SamsungDeviceInfo(Data(json.utf8)))
        #expect(info.name == "[TV] Soggiorno")
        #expect(info.model == "QE55Q80TATXZT")
        #expect(info.macAddress == "A0:B1:C2:D3:E4:F5")
        #expect(info.supportsToken)
    }
}
