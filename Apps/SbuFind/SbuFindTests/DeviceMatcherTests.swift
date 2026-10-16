import Foundation
import Testing
@testable import SbuFind

struct DeviceMatcherTests {
    private func heard(_ number: Int, name: String? = "Buds Pro", kind: DeviceKind = .earbuds, company: UInt16? = nil) -> NearbyDevice {
        NearbyDevice(id: Advertisement.testID(number), name: name, kind: kind, signal: -60, lastSeen: Advertisement.start, companyID: company)
    }

    private func saved(_ number: Int, as name: String = "Le mie", advertised: String? = "Buds Pro", kind: DeviceKind = .earbuds, company: UInt16? = nil) -> SavedDevice {
        SavedDevice(name: name, device: heard(number, name: advertised, kind: kind, company: company))
    }

    @Test func theSameIdentifierMatches() {
        let mine = saved(1)
        #expect(DeviceMatcher.match([mine], among: [heard(2), heard(1)])[mine.id]?.id == Advertisement.testID(1))
    }

    @Test func theSameIdentifierWinsEvenUnderAnotherName() {
        let mine = saved(1, advertised: "Old name")
        #expect(DeviceMatcher.match([mine], among: [heard(1, name: "New name")])[mine.id]?.id == Advertisement.testID(1))
    }

    @Test func aNewIdentifierMatchesByNameAndKind() {
        let mine = saved(1)
        #expect(DeviceMatcher.match([mine], among: [heard(5)])[mine.id]?.id == Advertisement.testID(5))
    }

    @Test(arguments: [
        ("Buds Pro", DeviceKind.headphones, nil as UInt16?),
        ("Buds Live", .earbuds, nil),
        ("Buds Pro", .earbuds, 0x0075),
    ])
    func anotherNameKindOrMakerDoesNotMatch(name: String, kind: DeviceKind, company: UInt16?) {
        let mine = saved(1, company: 0x004C)
        #expect(DeviceMatcher.match([mine], among: [heard(5, name: name, kind: kind, company: company)]).isEmpty)
    }

    @Test(arguments: [(nil as UInt16?, 0x004C as UInt16?), (0x004C, nil), (nil, nil), (0x004C, 0x004C)])
    func anUnknownMakerOnEitherSideStillMatches(savedCompany: UInt16?, heardCompany: UInt16?) {
        let mine = saved(1, company: savedCompany)
        #expect(DeviceMatcher.match([mine], among: [heard(5, company: heardCompany)]).count == 1)
    }

    /// Yours and a neighbour's: both say "Buds Pro". Neither is claimed.
    @Test func twoCandidatesAreAmbiguous() {
        let mine = saved(1)
        #expect(DeviceMatcher.match([mine], among: [heard(5), heard(6)]).isEmpty)
    }

    @Test func theMakerSettlesTwoCandidates() {
        let mine = saved(1, company: 0x004C)
        let matches = DeviceMatcher.match([mine], among: [heard(5, company: 0x0075), heard(6, company: 0x004C)])
        #expect(matches[mine.id]?.id == Advertisement.testID(6))
    }

    /// Two saved earbuds both called "Buds Pro", one heard under a new identifier: which one is it?
    @Test func twoSavedTwinsAreAmbiguous() {
        let left = saved(1, as: "Sinistro")
        let right = saved(2, as: "Destro")
        #expect(DeviceMatcher.match([left, right], among: [heard(5)]).isEmpty)
    }

    @Test func aTwinFoundByIdentifierLeavesTheOtherToTheName() {
        let left = saved(1, as: "Sinistro")
        let right = saved(2, as: "Destro")
        let matches = DeviceMatcher.match([left, right], among: [heard(1), heard(5)])
        #expect(matches[left.id]?.id == Advertisement.testID(1))
        #expect(matches[right.id]?.id == Advertisement.testID(5))
    }

    @Test func aDeviceIsClaimedOnce() {
        let first = saved(1)
        let second = saved(9, as: "Altro", advertised: "Buds Pro", kind: .earbuds)
        // Device 1 is claimed by its identifier; no other heard "Buds Pro" is left for the second.
        let matches = DeviceMatcher.match([first, second], among: [heard(1)])
        #expect(matches.count == 1)
        #expect(matches[first.id] != nil)
    }

    @Test func anUnnamedDeviceMatchesOnlyByIdentifier() {
        let mine = saved(1, advertised: nil, kind: .other)
        #expect(DeviceMatcher.match([mine], among: [heard(5, name: nil, kind: .other)]).isEmpty)
        #expect(DeviceMatcher.match([mine], among: [heard(1, name: nil, kind: .other)]).count == 1)
    }

    @Test func nothingHeardNothingMatched() {
        #expect(DeviceMatcher.match([saved(1)], among: []).isEmpty)
        #expect(DeviceMatcher.match([], among: [heard(1)]).isEmpty)
    }
}
