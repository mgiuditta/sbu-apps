import Testing
@testable import SbuRemote

/// Inputs come from the TV where the protocol lists them; elsewhere the Source key does the job.
struct SourceTests {
    @Test func samsungAndAndroidTVOnlyHaveTheSourceKey() async throws {
        #expect(try await SamsungClient(tv: .sample).inputs().isEmpty)
        #expect(try await AndroidTVClient(tv: .sample).inputs().isEmpty)
        #expect(SamsungMessage.keyCode(for: .source) == "KEY_SOURCE")
        #expect(AndroidKeyCode.code(for: .source) == 178)
    }

    @Test func lgSwitchesByInputID() throws {
        let request = try #require(JSONText.decode(LGMessage.request(id: "1", uri: LGMessage.URI.switchInput, payload: ["inputId": "HDMI_2"])))
        #expect((request["payload"] as? [String: String])?["inputId"] == "HDMI_2")
    }

    @Test func sonySwitchesByURI() {
        #expect(String(decoding: SonyRequest.switchInput(uri: "extInput:hdmi?port=2"), as: UTF8.self)
            == #"{"id":101,"method":"setPlayContent","params":[{"uri":"extInput:hdmi?port=2"}],"version":"1.0"}"#)
    }
}
