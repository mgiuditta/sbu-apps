import Foundation
import Testing
@testable import SbuTidy

struct RoomKindTests {
    @Test(arguments: RoomKind.allCases)
    func presetsHaveUniqueNamesInTheirRoom(kind: RoomKind) {
        let names = (kind.basePresets + kind.specialPresets).map { String(localized: $0.name) }
        #expect(Set(names).count == names.count)
        #expect(names.allSatisfy { !$0.trimmingCharacters(in: .whitespaces).isEmpty && $0.count <= ChoreDraft.maxNameLength })
    }

    @Test(arguments: RoomKind.allCases)
    func presetFrequenciesAreInRange(kind: RoomKind) {
        for preset in kind.basePresets + kind.specialPresets {
            #expect(preset.frequency.unit.range.contains(preset.frequency.value))
        }
    }

    @Test(arguments: RoomKind.allCases.filter { $0 != .other })
    func everyRealRoomComesWithBaseChores(kind: RoomKind) {
        #expect(!kind.basePresets.isEmpty)
    }

    @Test(arguments: RoomKind.allCases)
    func everyRoomOffersSomethingToAdd(kind: RoomKind) {
        #expect(!kind.specialPresets.isEmpty)
    }

    @Test func kindNamesFitARoomName() {
        let names = RoomKind.allCases.map { String(localized: $0.name) }
        #expect(Set(names).count == names.count)
        #expect(names.allSatisfy { $0.count <= RoomDraft.maxNameLength })
    }

    @Test(arguments: RoomKind.allCases)
    func rawValuesRoundTrip(kind: RoomKind) {
        #expect(RoomKind(rawValue: kind.rawValue) == kind)
    }
}
