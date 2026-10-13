import SwiftUI
import WidgetKit

@main
struct HabitsWidgetBundle: WidgetBundle {
    var body: some Widget {
        HabitsWidget()
        SingleHabitWidget()
        StreakWidget()
        RateWidget()
        WeekdaysWidget()
        CalendarWidget()
    }
}
