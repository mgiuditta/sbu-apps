import Foundation

extension HabitsFile {
    /// Three habits with a few weeks behind them, for the App Store screenshots.
    nonisolated static func demo(today: LogicalDay) -> HabitsFile {
        var water = Habit(title: String(localized: "Bere acqua"), symbol: "drop", timesPerDay: 8, createdOn: today - 30)
        var reading = Habit(title: String(localized: "Leggere"), symbol: "book", createdOn: today - 30)
        var walking = Habit(title: String(localized: "Camminare"), symbol: "figure.walk", createdOn: today - 30)
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
        return HabitsFile(habits: [water, reading, walking])
    }
}
