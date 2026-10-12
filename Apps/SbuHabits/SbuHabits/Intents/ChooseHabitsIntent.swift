import AppIntents

/// The grid widget's settings: which habits it shows. None chosen means all of today's.
struct ChooseHabitsIntent: WidgetConfigurationIntent {
    static let title: LocalizedStringResource = "Scegli le abitudini"
    static let description = IntentDescription("Lascia vuoto per vedere tutte le abitudini di oggi.")

    @Parameter(title: "Abitudini", default: [])
    var habits: [HabitEntity]
}
