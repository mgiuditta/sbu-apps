import Foundation
import Testing
@testable import SbuHabits

// TEMPORARY: seeds the app's tmp folder for the decisions screenshots. Not committed.
struct ZZDecisionSeed {
    @Test func seed() throws {
        let today = LogicalDay(.now)
        func timed(_ title: String, _ symbol: String, minutes: Int, streak: Int) -> Habit {
            var habit = Habit(title: title, symbol: symbol, createdOn: today - 40)
            _ = habit.update(title: title, symbol: symbol, timesPerDay: 1, schedule: .everyDay, timerMinutes: minutes, from: today - 40)
            for daysAgo in 1...streak { habit.log[today - daysAgo] = 1 }
            return habit
        }
        func plain(_ title: String, _ symbol: String, streak: Int = 0, times: Int = 1) -> Habit {
            var habit = Habit(title: title, symbol: symbol, timesPerDay: times, createdOn: today - 40)
            if streak > 0 { for daysAgo in 1...streak { habit.log[today - daysAgo] = times } }
            return habit
        }
        let many: [Habit] = [
            timed("Meditare", "figure.mind.and.body", minutes: 10, streak: 12),
            plain("Leggere", "book", streak: 5),
            plain("Bere acqua", "drop", streak: 3, times: 8),
            timed("Stretching", "figure.flexibility", minutes: 15, streak: 2),
            plain("Camminare", "figure.walk", streak: 9),
            plain("Diario", "pencil"),
            plain("Vitamine", "pill", streak: 20),
            plain("Chitarra", "guitars"),
        ]
        var full: [Habit] = []
        let symbols = ["book", "drop", "pencil", "pill", "guitars", "leaf", "bed.double", "fork.knife", "house", "phone", "dog", "camera"]
        for index in 0..<Habit.maxHabitsForSeed {
            if index % 5 == 0 {
                full.append(timed("Timer \(index + 1)", "timer", minutes: 10, streak: 11))
            } else {
                full.append(plain("Abitudine \(index + 1)", symbols[index % symbols.count], streak: index % 4))
            }
        }

        var new = Habit(title: "Nuova", symbol: "star", schedule: .timesPerWeek(3), createdOn: today)
        new.log = [:]
        var gym = Habit(title: "Palestra", symbol: "dumbbell", schedule: .timesPerWeek(3), createdOn: today - 60)
        var house = Habit(title: "Pulire casa", symbol: "house", schedule: .timesPerMonth(4), createdOn: today - 60)
        for daysAgo in [0, 2, 3, 8, 9, 11, 15, 17, 18, 22] { gym.log[today - daysAgo] = 1 }
        for daysAgo in [1, 6, 12, 20, 33, 40, 45] { house.log[today - daysAgo] = 1 }
        let stats = [new, gym, house]

        let folder = FileManager.default.temporaryDirectory
        for (name, habits) in [("dec-many.json", many), ("dec-full.json", full), ("dec-stats.json", stats), ("dec-empty.json", [])] {
            try HabitsStore(url: folder.appending(path: name)).save(HabitsFile(habits: habits))
        }
        print("SEEDED", folder.path)
    }
}

private extension Habit {
    static let maxHabitsForSeed = 24
}
