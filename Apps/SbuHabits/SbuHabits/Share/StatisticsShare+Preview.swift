extension StatisticsShare {
    /// Page `page` of `model`'s Statistiche over `period`, for previews.
    static func preview(_ model: HabitsModel, page: Int, period: StatisticsPeriod = .all) -> StatisticsShare {
        let habit = habit(on: page, in: model.habits)
        let statistics = if let habit {
            HabitStatistics.habit(habit, period: period, today: model.today, firstWeekday: model.firstWeekday)
        } else {
            HabitStatistics.all(model.habits, period: period, today: model.today, firstWeekday: model.firstWeekday)
        }
        return StatisticsShare(page: page, habits: model.habits, period: period, statistics: statistics)
    }
}
