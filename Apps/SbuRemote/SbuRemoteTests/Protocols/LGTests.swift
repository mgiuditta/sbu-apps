import Foundation
import Testing
@testable import SbuRemote

struct LGTests {
    @Test func urls() {
        #expect(LGMessage.url(host: "192.168.1.30", secure: true)?.absoluteString == "wss://192.168.1.30:3001")
        #expect(LGMessage.url(host: "192.168.1.30", secure: false)?.absoluteString == "ws://192.168.1.30:3000")
    }

    @Test func firstRegistrationAsksForThePrompt() throws {
        let json = try #require(JSONText.decode(LGMessage.register(clientKey: nil)))
        #expect(json["type"] as? String == "register")
        #expect(json["id"] as? String == "register_0")
        let payload = try #require(json["payload"] as? [String: Any])
        #expect(payload["pairingType"] as? String == "PROMPT")
        #expect(payload["client-key"] == nil)
        let manifest = try #require(payload["manifest"] as? [String: Any])
        #expect((manifest["permissions"] as? [String])?.contains("CONTROL_INPUT_TEXT") == true)
    }

    @Test func laterRegistrationsCarryTheClientKey() throws {
        let payload = try #require(JSONText.decode(LGMessage.register(clientKey: "abc123"))?["payload"] as? [String: Any])
        #expect(payload["client-key"] as? String == "abc123")
    }

    @Test func request() {
        #expect(LGMessage.request(id: "sbu_3", uri: "ssap://audio/setMute", payload: ["mute": true]) ==
            #"{"id":"sbu_3","payload":{"mute":true},"type":"request","uri":"ssap://audio/setMute"}"#)
        #expect(LGMessage.request(id: "sbu_4", uri: "ssap://audio/volumeUp") ==
            #"{"id":"sbu_4","type":"request","uri":"ssap://audio/volumeUp"}"#)
    }

    @Test func promptThenRegistered() throws {
        let prompt = try #require(LGReply(#"{"type":"response","id":"register_0","payload":{"pairingType":"PROMPT","returnValue":true}}"#))
        #expect(prompt.isWaitingForPrompt)
        #expect(prompt.clientKey == nil)
        let registered = try #require(LGReply(#"{"type":"registered","id":"register_0","payload":{"client-key":"f0e1d2"}}"#))
        #expect(registered.clientKey == "f0e1d2")
    }

    @Test func rejection() throws {
        let reply = try #require(LGReply(#"{"type":"error","id":"register_0","error":"403 User denied access","payload":{}}"#))
        #expect(reply.isError)
        #expect(reply.error == "403 User denied access")
    }

    @Test func listsAppsAndInputs() throws {
        let apps = try #require(LGReply(#"{"type":"response","id":"sbu_1","payload":{"returnValue":true,"launchPoints":[{"id":"youtube.leanback.v4","title":"YouTube"},{"id":"netflix","title":"Netflix"}]}}"#))
        #expect(apps.launchPoints == [TVShortcut(id: "youtube.leanback.v4", name: "YouTube"), TVShortcut(id: "netflix", name: "Netflix")])
        let inputs = try #require(LGReply(#"{"type":"response","id":"sbu_2","payload":{"devices":[{"id":"HDMI_1","label":"HDMI 1"},{"id":"HDMI_2"}]}}"#))
        #expect(inputs.inputs == [TVShortcut(id: "HDMI_1", name: "HDMI 1"), TVShortcut(id: "HDMI_2", name: "HDMI_2")])
    }

    @Test func socketMuteAndNetwork() throws {
        let socket = try #require(LGReply(#"{"type":"response","id":"sbu_5","payload":{"socketPath":"wss://192.168.1.30:3001/resources/abc/netinput.pointer.sock"}}"#))
        #expect(socket.socketPath?.scheme == "wss")
        #expect(try #require(LGReply(#"{"type":"response","payload":{"mute":true}}"#)).isMuted == true)
        #expect(try #require(LGReply(#"{"type":"response","payload":{"muteStatus":false}}"#)).isMuted == false)
        let network = try #require(LGReply(#"{"type":"response","payload":{"wifiInfo":{"macAddress":"a0:b1:c2:d3:e4:f5"},"wiredInfo":{"macAddress":"00:00:00:00:00:00"}}}"#))
        #expect(network.macAddress == "A0:B1:C2:D3:E4:F5")
    }

    @Test func pointerMessages() {
        #expect(LGPointerMessage.button("UP") == "type:button\nname:UP\n\n")
        #expect(LGPointerMessage.move(dx: 3.6, dy: -2.2) == "type:move\ndx:4\ndy:-2\ndown:0\n\n")
        #expect(LGPointerMessage.click == "type:click\n\n")
    }

    @Test(arguments: [
        (RemoteKey.select, "ENTER"),
        (.back, "BACK"),
        (.home, "HOME"),
        (.left, "LEFT"),
    ])
    func navigationGoesThroughThePointer(key: RemoteKey, name: String) {
        #expect(LGPointerMessage.buttonName(for: key) == name)
        #expect(LGMessage.uri(for: key) == nil)
    }

    @Test(arguments: [
        ("", "ciao", 0, "ciao"),
        ("cia", "ciao", 0, "o"),
        ("ciao", "cia", 1, ""),
        ("ciao", "cibo", 2, "bo"),
        ("ciao", "", 4, ""),
    ])
    func textEdit(old: String, new: String, deleteCount: Int, insert: String) {
        #expect(TextEdit(from: old, to: new) == TextEdit(deleteCount: deleteCount, insert: insert))
    }
}

private extension TextEdit {
    init(deleteCount: Int, insert: String) {
        self = TextEdit(from: String(repeating: "x", count: deleteCount), to: insert)
    }
}
