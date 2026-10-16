import Foundation
import SwiftData

/// A made-up home for previews and screenshots, never the user's own: four rooms, some chores
/// done long ago, some just done, one paused.
enum SampleHome {
    static func insert(into context: ModelContext, now: Date, calendar: Calendar) {
        func daysAgo(_ days: Int) -> Date {
            calendar.date(byAdding: .day, value: -days, to: now) ?? now
        }
        // Days since last done for each base chore, in the order of `RoomKind.basePresets`.
        let plan: [(RoomKind, [Int])] = [
            (.kitchen, [1, 3, 2, 9, 1, 4]),
            (.bathroom, [10, 3, 8, 2, 7, 4]),
            (.livingRoom, [3, 12, 1, 6]),
            (.bedroom, [8, 5, 2, 1]),
        ]
        for (kind, ages) in plan {
            var draft = RoomDraft(kind: kind)
            draft.addsBaseChores = false
            let room = Home.addRoom(draft, in: context, now: now)
            for (preset, age) in zip(kind.basePresets, ages) {
                let chore = Home.addChore(ChoreDraft(preset: preset, lastDone: daysAgo(age + 30)), to: room, in: context, now: now)
                // A short history, so the chore's screen has one to show.
                for back in [age + 2 * preset.frequency.value, age] {
                    chore.markDone(at: daysAgo(back), now: now, in: context)
                }
            }
        }
        if let special = RoomKind.kitchen.specialPresets.first,
           let kitchen = try? context.fetch(FetchDescriptor<Room>()).first(where: { $0.kind == .kitchen }) {
            let fridge = Home.addChore(ChoreDraft(preset: special, lastDone: daysAgo(20)), to: kitchen, in: context, now: now)
            fridge.pause(at: daysAgo(2))
        }
    }
}
