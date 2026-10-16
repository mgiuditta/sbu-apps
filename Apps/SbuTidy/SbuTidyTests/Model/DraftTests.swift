import Foundation
import Testing
@testable import SbuTidy

struct DraftTests {
    @Test(arguments: ["", " ", "\n\t  ", "   \n"])
    func blankNamesAreNotValid(name: String) {
        var chore = ChoreDraft()
        chore.name = name
        var room = RoomDraft()
        room.name = name
        #expect(!chore.isValid)
        #expect(!room.isValid)
    }

    @Test func namesAreTrimmedAndCut() {
        var chore = ChoreDraft()
        chore.name = "  " + String(repeating: "a", count: 500) + "  "
        var room = RoomDraft()
        room.name = String(repeating: "🧽", count: 200)
        #expect(chore.cleanName.count == ChoreDraft.maxNameLength)
        #expect(room.cleanName.count == RoomDraft.maxNameLength)
        #expect(chore.isValid && room.isValid)
    }

    @Test func notesAreCut() {
        var chore = ChoreDraft()
        chore.notes = String(repeating: "x", count: 50_000)
        #expect(chore.cleanNotes.count == ChoreDraft.maxNotesLength)
    }

    @Test(arguments: [(30, FrequencyUnit.month, 24), (400, .week, 52), (0, .day, 1), (3, .week, 3)])
    func changingUnitKeepsTheValueInRange(value: Int, unit: FrequencyUnit, expected: Int) {
        var chore = ChoreDraft()
        chore.frequencyValue = value
        chore.select(unit)
        #expect(chore.frequencyValue == expected)
        #expect(chore.frequency == Frequency(expected, unit))
    }

    @Test func aLastDoneDateInTheFutureStartsNow() {
        let draft = ChoreDraft(lastDone: Fixtures.now.addingTimeInterval(86_400 * 3))
        #expect(draft.startDate(now: Fixtures.now) == Fixtures.now)
        #expect(ChoreDraft(lastDone: Fixtures.daysAgo(2)).startDate(now: Fixtures.now) == Fixtures.daysAgo(2))
    }

    @Test func presetFillsTheDraft() throws {
        let preset = try #require(RoomKind.bathroom.basePresets.first)
        let draft = ChoreDraft(preset: preset)
        #expect(draft.cleanName == String(localized: preset.name))
        #expect(draft.frequency == preset.frequency)
        #expect(draft.effort == preset.effort)
    }

    @Test func pickingAKindRenamesOnlyAnUntouchedName() {
        var room = RoomDraft(kind: .kitchen)
        room.select(.bathroom)
        #expect(room.name == String(localized: RoomKind.bathroom.name))
        room.name = "Bagno degli ospiti"
        room.select(.laundry)
        #expect(room.name == "Bagno degli ospiti")
        #expect(room.kind == .laundry)
    }

    @Test func pickingAKindFillsAnEmptyName() {
        var room = RoomDraft(kind: .kitchen, name: "  ")
        room.select(.garden)
        #expect(room.name == String(localized: RoomKind.garden.name))
    }

    @Test(arguments: [(Int.min, Effort.light), (0, .light), (1, .light), (2, .medium), (3, .heavy), (4, .heavy), (Int.max, .heavy)])
    func effortClampsAnyStoredNumber(value: Int, expected: Effort) {
        #expect(Effort(clamping: value) == expected)
    }
}
