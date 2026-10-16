import CryptoKit
import Foundation
import Security
import Testing
@testable import SbuRemote

struct AndroidTVTests {
    // MARK: Protobuf

    @Test(arguments: [
        (0, [0x00]),
        (1, [0x01]),
        (127, [0x7f]),
        (128, [0x80, 0x01]),
        (300, [0xac, 0x02]),
        (622, [0xee, 0x04]),
    ])
    func varint(value: Int, bytes: [UInt8]) {
        var data = Data()
        ProtobufWriter.appendVarint(UInt64(value), to: &data)
        #expect([UInt8](data) == bytes)
        var index = 0
        #expect(ProtobufReader.readVarint(bytes, &index) == UInt64(value))
    }

    @Test func writerAndReaderAgree() throws {
        var writer = ProtobufWriter()
        writer.varint(1, 200)
        writer.string(2, "ciao")
        writer.message(3) { $0.varint(1, 7) }
        let reader = try #require(ProtobufReader(writer.data))
        #expect(reader.varints[1] == 200)
        #expect(reader.string(2) == "ciao")
        #expect(reader.message(3)?.varints[1] == 7)
    }

    @Test func truncatedMessageIsRejected() {
        #expect(ProtobufReader(Data([0x12, 0x05, 0x61])) == nil)
    }

    @Test func delimitedFramesSplitAcrossReads() {
        var buffer = ProtobufWriter.delimited(Data([1, 2, 3])) + ProtobufWriter.delimited(Data([4]))
        let tail = buffer.suffix(1)
        buffer.removeLast()
        #expect(ProtobufReader.takeDelimited(from: &buffer) == [Data([1, 2, 3])])
        #expect(buffer == Data([0x01]))
        buffer.append(tail)
        #expect(ProtobufReader.takeDelimited(from: &buffer) == [Data([4])])
        #expect(buffer.isEmpty)
    }

    // MARK: Pairing (Polo)

    @Test func pairingRequestBytes() {
        // version 2, status 200, field 10 { 1: "atvremote", 2: "Sbu" }
        let expected: [UInt8] = [0x08, 0x02, 0x10, 0xc8, 0x01, 0x52, 0x10,
                                 0x0a, 0x09] + Array("atvremote".utf8) + [0x12, 0x03] + Array("Sbu".utf8)
        #expect([UInt8](PoloMessage.pairingRequest(clientName: "Sbu")) == expected)
    }

    @Test func optionsAskForASixCharacterHexCode() {
        let expected: [UInt8] = [0x08, 0x02, 0x10, 0xc8, 0x01, 0xa2, 0x01, 0x08, 0x0a, 0x04, 0x08, 0x03, 0x10, 0x06, 0x18, 0x01]
        #expect([UInt8](PoloMessage.options()) == expected)
    }

    @Test func configurationTakesTheInputRole() {
        let expected: [UInt8] = [0x08, 0x02, 0x10, 0xc8, 0x01, 0xf2, 0x01, 0x08, 0x0a, 0x04, 0x08, 0x03, 0x10, 0x06, 0x10, 0x01]
        #expect([UInt8](PoloMessage.configuration()) == expected)
    }

    @Test func replies() throws {
        var ack = ProtobufWriter()
        ack.varint(1, 2)
        ack.varint(2, 200)
        ack.message(11) { _ in }
        #expect(try #require(PoloReply(ack.data)) == PoloReply(kind: .pairingRequestAck, status: 200))

        var bad = ProtobufWriter()
        bad.varint(1, 2)
        bad.varint(2, 402)
        let reply = try #require(PoloReply(bad.data))
        #expect(!reply.isOK)
    }

    @Test func secretIsTheHashOfBothKeysAndTheCode() throws {
        let client = RSAPublicKeyNumbers(modulus: Data([0x00, 0xc1, 0x02]), exponent: Data([0x01, 0x00, 0x01]))
        let server = RSAPublicKeyNumbers(modulus: Data([0xd3, 0x04]), exponent: Data([0x03]))
        let nonce = Data([0xab, 0xcd])
        let digest = Data(SHA256.hash(data: Data([0xc1, 0x02, 0x01, 0x00, 0x01, 0xd3, 0x04, 0x03]) + nonce))
        let code = Data([digest[0]]).hexString + "abcd"

        #expect(PairingSecret.secret(client: client, server: server, code: code) == digest)
        #expect(PairingSecret.secret(client: client, server: server, code: code.uppercased()) == digest)
    }

    @Test func aTypoFailsTheCheckDigit() {
        let client = RSAPublicKeyNumbers(modulus: Data([0xc1]), exponent: Data([0x03]))
        let server = RSAPublicKeyNumbers(modulus: Data([0xd3]), exponent: Data([0x03]))
        let digest = Data(SHA256.hash(data: Data([0xc1, 0x03, 0xd3, 0x03, 0x12, 0x34])))
        let wrongCheck = Data([digest[0] &+ 1]).hexString + "1234"
        #expect(PairingSecret.secret(client: client, server: server, code: wrongCheck) == nil)
        #expect(PairingSecret.secret(client: client, server: server, code: "12345") == nil)
        #expect(PairingSecret.secret(client: client, server: server, code: "zz1234") == nil)
    }

    // MARK: Remote

    @Test func keyInjectCarriesCodeAndDirection() {
        // field 10 { 1: 24 (volume up), 2: 1 (start long) }
        #expect([UInt8](AndroidRemoteMessage.key(24, action: .press)) == [0x52, 0x04, 0x08, 0x18, 0x10, 0x01])
        #expect([UInt8](AndroidRemoteMessage.key(24, action: .click)) == [0x52, 0x04, 0x08, 0x18, 0x10, 0x03])
        #expect([UInt8](AndroidRemoteMessage.key(24, action: .release)) == [0x52, 0x04, 0x08, 0x18, 0x10, 0x02])
    }

    @Test func answersAreWellFormed() throws {
        #expect([UInt8](AndroidRemoteMessage.pingResponse(5)) == [0x4a, 0x02, 0x08, 0x05])
        #expect([UInt8](AndroidRemoteMessage.setActive()) == [0x12, 0x03, 0x08, 0xee, 0x04])
        let configure = try #require(ProtobufReader(AndroidRemoteMessage.configure())?.message(1))
        #expect(configure.varints[1] == 622)
        #expect(configure.message(2)?.string(5) == "dev.sbu.remote")
    }

    @Test func appLinkAndText() throws {
        let link = try #require(ProtobufReader(AndroidRemoteMessage.appLink("https://www.youtube.com"))?.message(90))
        #expect(link.string(1) == "https://www.youtube.com")
        let edit = try #require(ProtobufReader(AndroidRemoteMessage.text("ciao", imeCounter: 3, fieldCounter: 9))?.message(21))
        #expect(edit.varints[1] == 3)
        #expect(edit.varints[2] == 9)
        #expect(edit.message(3)?.message(2)?.string(3) == "ciao")
    }

    @Test func events() {
        var ping = ProtobufWriter()
        ping.message(8) { $0.varint(1, 42) }
        #expect(AndroidRemoteEvent(ping.data) == .ping(42))

        var configure = ProtobufWriter()
        configure.message(1) { $0.varint(1, 1) }
        #expect(AndroidRemoteEvent(configure.data) == .configure)

        var ime = ProtobufWriter()
        ime.message(21) { edit in
            edit.varint(1, 4)
            edit.varint(2, 2)
        }
        #expect(AndroidRemoteEvent(ime.data) == .ime(imeCounter: 4, fieldCounter: 2))
        #expect(AndroidRemoteEvent(Data([0xff])) == .other)
    }

    @Test(arguments: [
        (RemoteKey.home, 3), (.back, 4), (.select, 23), (.volumeUp, 24), (.mute, 164), (.source, 178), (.power, 26),
    ])
    func keyCodes(key: RemoteKey, code: Int) {
        #expect(AndroidKeyCode.code(for: key) == code)
    }

    @Test func everyKeyHasACode() {
        #expect(RemoteKey.allCases.allSatisfy { AndroidKeyCode.code(for: $0) != nil })
    }

    @Test func appLinksAreHTTPS() {
        #expect(AndroidAppLinks.all.allSatisfy { $0.id.hasPrefix("https://") })
    }
}

private extension PoloReply {
    init?(kind: Kind, status: Int) {
        var writer = ProtobufWriter()
        writer.varint(2, status)
        switch kind {
        case .pairingRequestAck: writer.message(11) { _ in }
        case .options: writer.message(20) { _ in }
        case .configurationAck: writer.message(31) { _ in }
        case .secretAck: writer.message(41) { _ in }
        case .other: break
        }
        self.init(writer.data)
    }
}
