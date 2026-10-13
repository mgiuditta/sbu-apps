import Foundation
import ImageIO
import Testing
@testable import SbuHabits

struct StatisticsShareTests {
    nonisolated private static let italian = Locale(identifier: "it_IT")
    nonisolated private static let american = Locale(identifier: "en_US")

    private let today = LogicalDay(ordinal: 1_004)
    private let monday = 2

    /// A habit done every day of the last `days`, today included.
    private func habit(_ title: String = "Leggere", _ schedule: Schedule = .everyDay, days: Int = 30) -> Habit {
        var habit = Habit(title: title, symbol: "book", schedule: schedule, createdOn: today - (days - 1))
        for daysAgo in 0..<days {
            habit.log[today - daysAgo] = 1
        }
        return habit
    }

    private func share(page: Int, of habits: [Habit], period: StatisticsPeriod = .month) -> StatisticsShare {
        let statistics = if let habit = StatisticsShare.habit(on: page, in: habits) {
            HabitStatistics.habit(habit, period: period, today: today, firstWeekday: monday)
        } else {
            HabitStatistics.all(habits, period: period, today: today, firstWeekday: monday)
        }
        return StatisticsShare(page: page, habits: habits, period: period, statistics: statistics)
    }

    // MARK: Which page

    @Test(arguments: [
        (0, nil), // every habit
        (1, "Leggere"),
        (2, "Camminare"),
        (3, nil), // past the habits, once one was deleted
        (-1, nil),
    ] as [(Int, String?)])
    func thePageOnShowPicksTheHabit(page: Int, title: String?) {
        let habits = [habit("Leggere"), habit("Camminare")]

        #expect(StatisticsShare.habit(on: page, in: habits)?.title == title)
        #expect(share(page: page, of: habits).habitTitle == title)
    }

    @Test func theHabitsPageTakesItsSymbolAndItsUnit() {
        let gym = Habit(title: "Palestra", symbol: "dumbbell", schedule: .timesPerWeek(3), createdOn: today - 10)

        let share = share(page: 1, of: [gym])

        #expect(share.symbol == "dumbbell")
        #expect(share.streakSchedule == .timesPerWeek(3))
    }

    @Test func thePageOfEveryHabitHasNoSymbolAndCountsDays() {
        let share = share(page: 0, of: [Habit(title: "Palestra", symbol: "dumbbell", schedule: .timesPerWeek(3), createdOn: today)])

        #expect(share.symbol == nil)
        #expect(share.streakSchedule == .everyDay)
    }

    @Test(arguments: StatisticsPeriod.allCases)
    func thePeriodChosenGoesIntoTheImage(period: StatisticsPeriod) {
        let habits = [habit()]

        let share = share(page: 1, of: habits, period: period)

        #expect(share.period == period)
        #expect(share.statistics == .habit(habits[0], period: period, today: today, firstWeekday: monday))
    }

    // MARK: Words

    @Test(arguments: [
        (1, StatisticsPeriod.month, italian, "Sbu Habits · Leggere · Ultimi 30 giorni"),
        (0, .all, italian, "Sbu Habits · Tutte le abitudini · Dall'inizio"),
        (1, .month, american, "Sbu Habits · Leggere · Last 30 days"),
        (0, .all, american, "Sbu Habits · All habits · All time"),
    ])
    func theTitleNamesThePageAndThePeriod(page: Int, period: StatisticsPeriod, locale: Locale, title: String) {
        #expect(share(page: page, of: [habit()], period: period).title(locale: locale) == title)
    }

    @Test(arguments: [
        ("Leggere", "Sbu Habits - Leggere - Ultimi 30 giorni"),
        ("Leggere/Scrivere", "Sbu Habits - Leggere-Scrivere - Ultimi 30 giorni"),
        ("Ore: 7", "Sbu Habits - Ore- 7 - Ultimi 30 giorni"),
        ("Due\nrighe", "Sbu Habits - Due-righe - Ultimi 30 giorni"),
    ])
    func theFileNameIsTheTitleWithoutUnsafeCharacters(title: String, fileName: String) {
        #expect(share(page: 1, of: [habit(title)]).fileName(locale: Self.italian) == fileName)
    }

    @Test func theDescriptionSaysWhatTheImageShows() {
        let share = share(page: 1, of: [habit()])

        #expect(share.imageDescription(locale: Self.italian) == "Leggere, Ultimi 30 giorni: completamento 100%, serie migliore 30 giorni, completamenti 30.")
        #expect(share.imageDescription(locale: Self.american) == "Leggere, Last 30 days: completion 100%, best streak 30 days, completions 30.")
    }

    @Test func nothingExpectedIsAnEnDashNotZero() {
        // Created today and not done yet: today is not over, nothing counts.
        let share = share(page: 1, of: [Habit(title: "Leggere", symbol: "book", schedule: .everyDay, createdOn: today)])

        #expect(share.rate(locale: Self.italian) == "–")
    }

    // MARK: Picture

    @Test(arguments: [0, 1])
    func theRendererDrawsTheFullSizePicture(page: Int) throws {
        let share = share(page: page, of: [habit(), habit("Camminare", days: 12)])

        let image = try #require(StatisticsShareRenderer.image(of: share)?.cgImage)

        #expect(image.width == 1080)
        #expect(image.height == 1920)
    }

    @Test func thePNGCarriesItsDescription() throws {
        let share = share(page: 1, of: [habit()])

        let data = try #require(StatisticsShareRenderer.png(of: share))
        let source = try #require(CGImageSourceCreateWithData(data as CFData, nil))
        let properties = try #require(CGImageSourceCopyPropertiesAtIndex(source, 0, nil) as? [CFString: Any])
        let png = try #require(properties[kCGImagePropertyPNGDictionary] as? [CFString: Any])

        #expect(properties[kCGImagePropertyPixelWidth] as? Int == 1080)
        #expect(properties[kCGImagePropertyPixelHeight] as? Int == 1920)
        #expect(png[kCGImagePropertyPNGDescription] as? String == share.imageDescription())
    }
}
