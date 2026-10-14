import AppIntents

/// The widget's one setting: a list to show, or every subscription.
struct ChooseListIntent: WidgetConfigurationIntent {
    static let title: LocalizedStringResource = "Scegli la lista"
    static let description = IntentDescription("Lascia vuoto per vedere tutti gli abbonamenti.")

    @Parameter(title: "Lista")
    var list: ListEntity?
}
