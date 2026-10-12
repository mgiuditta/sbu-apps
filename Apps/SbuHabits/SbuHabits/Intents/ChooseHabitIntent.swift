import AppIntents

/// The single-habit widget's settings. None chosen means the first habit still to do today.
struct ChooseHabitIntent: WidgetConfigurationIntent {
    static let title: LocalizedStringResource = "Scegli un'abitudine"
    static let description = IntentDescription("Lascia vuoto per vedere la prima abitudine da fare oggi.")

    @Parameter(title: "Abitudine")
    var habit: HabitEntity?
}
