import Foundation
import SwiftData

/// What you do to the rooms and chores, in one place for the screens and the tests.
enum Home {
    @discardableResult
    static func addRoom(_ draft: RoomDraft, in context: ModelContext, now: Date = .now) -> Room {
        let rooms = (try? context.fetch(FetchDescriptor<Room>())) ?? []
        let room = Room(name: draft.cleanName, kind: draft.kind, order: (rooms.map(\.order).max() ?? -1) + 1)
        context.insert(room)
        if draft.addsBaseChores {
            for preset in draft.kind.basePresets {
                addChore(ChoreDraft(preset: preset, lastDone: now), to: room, in: context, now: now)
            }
        }
        return room
    }

    static func update(_ room: Room, with draft: RoomDraft) {
        guard draft.isValid else { return }
        room.name = draft.cleanName
        room.kind = draft.kind
    }

    @discardableResult
    static func addChore(_ draft: ChoreDraft, to room: Room, in context: ModelContext, now: Date = .now) -> Chore {
        let chore = Chore(name: draft.cleanName, frequency: draft.frequency, effort: draft.effort, lastDone: draft.startDate(now: now))
        chore.notes = draft.cleanNotes
        chore.isOneOff = draft.isOneOff
        context.insert(chore)
        chore.room = room
        return chore
    }

    static func update(_ chore: Chore, with draft: ChoreDraft) {
        guard draft.isValid else { return }
        chore.name = draft.cleanName
        chore.frequency = draft.frequency
        chore.effort = draft.effort
        chore.isOneOff = draft.isOneOff
        chore.notes = draft.cleanNotes
    }

    /// A copy of the room right after it, with the same chores just done: a second bathroom
    /// starts clean. Tody crashes here; this only inserts.
    @discardableResult
    static func duplicate(_ room: Room, in context: ModelContext, now: Date = .now) -> Room {
        let rooms = (try? context.fetch(FetchDescriptor<Room>())) ?? []
        for other in rooms where other.order > room.order {
            other.order += 1
        }
        let copy = Room(name: copyName(of: room.name, existing: rooms.map(\.name)), kind: room.kind, order: room.order + 1)
        context.insert(copy)
        for chore in room.choreList.sorted(by: { $0.createdAt < $1.createdAt }) {
            var draft = ChoreDraft(lastDone: now)
            draft.name = chore.name
            draft.frequencyValue = chore.frequency.value
            draft.frequencyUnit = chore.frequency.unit
            draft.effort = chore.effort
            draft.isOneOff = chore.isOneOff
            draft.notes = chore.notes
            addChore(draft, to: copy, in: context, now: now)
        }
        return copy
    }

    /// "Bagno 2", or "Bagno 3" when "Bagno 2" exists: never two rooms with the same name.
    static func copyName(of name: String, existing: [String]) -> String {
        let base = String(name.prefix(RoomDraft.maxNameLength - 4))
        var number = 2
        while existing.contains("\(base) \(number)") { number += 1 }
        return "\(base) \(number)"
    }

    /// Rooms moved in the list: the orders become 0, 1, 2… in the new sequence.
    static func move(_ rooms: [Room], from source: IndexSet, to destination: Int) {
        var ordered = rooms
        ordered.move(fromOffsets: source, toOffset: destination)
        for (index, room) in ordered.enumerated() where room.order != index {
            room.order = index
        }
    }

    static func delete(_ room: Room, in context: ModelContext) {
        context.delete(room)
    }

    static func delete(_ chore: Chore, in context: ModelContext) {
        context.delete(chore)
    }
}
