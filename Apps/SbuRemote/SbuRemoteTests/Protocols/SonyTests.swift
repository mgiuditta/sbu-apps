import Foundation
import Testing
@testable import SbuRemote

struct SonyTests {
    @Test func endpoints() {
        #expect(SonyRequest.url(host: "192.168.1.40", service: .system)?.absoluteString == "http://192.168.1.40/sony/system")
        #expect(SonyRequest.irccURL(host: "192.168.1.40")?.absoluteString == "http://192.168.1.40/sony/IRCC")
    }

    @Test func jsonRPCBody() {
        #expect(String(decoding: SonyRequest.powerOn, as: UTF8.self) ==
            #"{"id":55,"method":"setPowerStatus","params":[{"status":true}],"version":"1.0"}"#)
    }

    @Test func registrationAsksForWakeOnLAN() throws {
        let json = try #require(JSONText.decode(String(decoding: SonyRequest.register, as: UTF8.self)))
        #expect(json["method"] as? String == "actRegister")
        let params = try #require(json["params"] as? [Any])
        #expect((params.first as? [String: String])?["nickname"] == "Sbu Remote")
        #expect(((params.last as? [[String: String]])?.first)?["function"] == "WOL")
    }

    @Test func pinGoesAsBasicWithEmptyUser() {
        #expect(SonyRequest.pinAuthorization("1234") == "Basic OjEyMzQ=")
    }

    @Test(arguments: [
        ("auth=A1B2C3; Path=/sony/; Max-Age=1209600; Expires=Fri, 30 Oct 2026 10:00:00 GMT", "auth=A1B2C3"),
        ("other=1; auth=XYZ", "auth=XYZ"),
    ])
    func authCookie(header: String, cookie: String) {
        #expect(SonyRequest.authCookie(fromSetCookie: header) == cookie)
    }

    @Test func noAuthCookie() {
        #expect(SonyRequest.authCookie(fromSetCookie: "auth=; Path=/") == nil)
        #expect(SonyRequest.authCookie(fromSetCookie: "session=1") == nil)
    }

    @Test func irccEnvelope() {
        let xml = String(decoding: SonyRequest.ircc("AAAAAQAAAAEAAAASAw=="), as: UTF8.self)
        #expect(xml.contains("<u:X_SendIRCC xmlns:u=\"urn:schemas-sony-com:service:IRCC:1\"><IRCCCode>AAAAAQAAAAEAAAASAw==</IRCCCode>"))
        #expect(xml.hasPrefix("<?xml version=\"1.0\"?><s:Envelope"))
    }

    @Test func remoteCodesAndFallbackNames() throws {
        let json = #"{"result":[{"bundled":true,"type":"RM-J1100"},[{"name":"PowerOff","value":"AAAAAQAAAAEAAAAvAw=="},{"name":"VolumeUp","value":"AAAAAQAAAAEAAAASAw=="},{"name":"Return","value":"AAAAAgAAAJcAAAAjAw=="},{"name":"Pause","value":"AAAAAgAAAJcAAAAZAw=="}]],"id":10}"#
        let codes = try #require(SonyReply(Data(json.utf8))).remoteCodes
        #expect(SonyReply.code(for: .volumeUp, in: codes) == "AAAAAQAAAAEAAAASAw==")
        #expect(SonyReply.code(for: .power, in: codes) == "AAAAAQAAAAEAAAAvAw==")
        #expect(SonyReply.code(for: .back, in: codes) == "AAAAAgAAAJcAAAAjAw==")
        #expect(SonyReply.code(for: .playPause, in: codes) == "AAAAAgAAAJcAAAAZAw==")
        #expect(SonyReply.code(for: .mute, in: codes) == nil)
    }

    @Test func inputsUseTheUserLabel() throws {
        let json = #"{"result":[[{"uri":"extInput:hdmi?port=1","title":"HDMI 1","label":"PlayStation","connection":true},{"uri":"extInput:hdmi?port=2","title":"HDMI 2","label":""}]],"id":105}"#
        #expect(try #require(SonyReply(Data(json.utf8))).inputs == [
            TVShortcut(id: "extInput:hdmi?port=1", name: "PlayStation"),
            TVShortcut(id: "extInput:hdmi?port=2", name: "HDMI 2"),
        ])
    }

    @Test func applicationsAndSystemInformation() throws {
        let apps = #"{"result":[[{"title":"YouTube","uri":"com.sony.dtv.com.google.android.youtube.tv"}]],"id":60}"#
        #expect(try #require(SonyReply(Data(apps.utf8))).applications == [TVShortcut(id: "com.sony.dtv.com.google.android.youtube.tv", name: "YouTube")])
        let info = #"{"result":[{"product":"TV","name":"BRAVIA","model":"KD-55XE9005","macAddr":"fc:f1:52:aa:bb:cc"}],"id":33}"#
        #expect(try #require(SonyReply(Data(info.utf8))).systemInformation == TVDetails(name: "BRAVIA", model: "KD-55XE9005", macAddress: "FC:F1:52:AA:BB:CC"))
    }

    @Test func errorReply() throws {
        let reply = try #require(SonyReply(Data(#"{"error":[40005,"Display Is Turned off"],"id":1}"#.utf8)))
        #expect(reply.errorCode == 40005)
    }
}
