import Foundation
import Testing
@testable import SbuFind

struct AdvertisementTests {
    @Test(arguments: [
        ("Buds Pro", "Buds Pro"),
        ("  Buds Pro \n", "Buds Pro"),
        ("", nil),
        ("   ", nil),
        ("\n\t", nil),
    ] as [(String, String?)])
    func nameIsTrimmedAndBlankIsNone(raw: String, expected: String?) {
        #expect(Advertisement.fixture(name: raw).name == expected)
    }

    @Test func missingNameStaysNone() {
        #expect(Advertisement.fixture(name: nil).name == nil)
    }

    @Test(arguments: [
        (-1, true),
        (-30, true),
        (-100, true),
        (-127, true),
        (-128, false),
        (0, false),
        (127, false),
        (20, false),
    ])
    func onlyNegativeReadingsAreValid(rssi: Int, isValid: Bool) {
        #expect(Advertisement.fixture(rssi: rssi).hasValidRSSI == isValid)
    }

    @Test(arguments: [
        (nil, nil),
        (Data(), nil),
        (Data([0x4C]), nil),
        (Data([0x4C, 0x00]), 0x004C),
        (Data([0x75, 0x00, 0x01]), 0x0075),
        (Data([0x00, 0x01]), 0x0100),
    ] as [(Data?, UInt16?)])
    func companyIDIsLittleEndian(data: Data?, expected: UInt16?) {
        #expect(Advertisement.fixture(manufacturerData: data).companyID == expected)
    }

    @Test func messageTypeNeedsThreeBytes() {
        #expect(Advertisement.fixture(manufacturerData: Data([0x4C, 0x00])).manufacturerMessageType == nil)
        #expect(Advertisement.fixture(manufacturerData: Data([0x4C, 0x00, 0x07, 0x19])).manufacturerMessageType == 0x07)
    }

    @Test func messageTypeReadsASliceFromItsOwnStart() {
        let slice = Data([0xFF, 0x4C, 0x00, 0x10]).dropFirst()
        let advertisement = Advertisement.fixture(manufacturerData: slice)
        #expect(advertisement.companyID == 0x004C)
        #expect(advertisement.manufacturerMessageType == 0x10)
    }

    @Test func namedAndHeardKeepEverythingElse() {
        let original = Advertisement.fixture(name: "A", rssi: -50, manufacturerData: Data([1, 2, 3]), serviceUUIDs: ["180D"])
        let renamed = original.named("B")
        #expect(renamed.name == "B")
        #expect(renamed.rssi == -50 && renamed.id == original.id && renamed.serviceUUIDs == ["180D"] && renamed.manufacturerData == original.manufacturerData)

        let later = Date(timeIntervalSinceReferenceDate: 99)
        let heard = original.heard(at: later)
        #expect(heard.date == later)
        #expect(heard.named(original.name) == original.heard(at: later))
    }
}
