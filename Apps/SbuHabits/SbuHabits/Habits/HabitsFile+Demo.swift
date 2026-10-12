import Foundation

extension HabitsFile {
    /// Four habits with a few weeks behind them, for the App Store screenshots: one counted,
    /// one done once, one linked to Salute and one Abitudine da evitare.
    nonisolated static func demo(today: LogicalDay) -> HabitsFile {
        var water = Habit(title: String(localized: "Bere acqua"), symbol: "drop", timesPerDay: 8, createdOn: today - 30)
        var reading = Habit(title: String(localized: "Leggere"), symbol: "book", createdOn: today - 30)
        var walking = Habit(title: String(localized: "Camminare"), symbol: "figure.walk", createdOn: today - 30)
        _ = walking.update(title: walking.title, symbol: walking.symbol, timesPerDay: 1, schedule: .everyDay, health: HealthLink(measure: .steps, goal: HealthMeasure.steps.defaultGoal), from: today)
        var coffee = Habit(title: String(localized: "Caffè"), symbol: "cup.and.saucer", limit: 2, createdOn: today - 30)
        for daysAgo in 1...12 {
            water.log[today - daysAgo] = 8
        }
        water.log[today] = 5
        for daysAgo in 0...20 {
            reading.log[today - daysAgo] = 1
        }
        for daysAgo in 1...9 {
            walking.log[today - daysAgo] = 1
        }
        for daysAgo in 1...14 {
            coffee.log[today - daysAgo] = 2
        }
        coffee.log[today] = 1
        return HabitsFile(habits: [water, reading, walking, coffee])
    }
}
