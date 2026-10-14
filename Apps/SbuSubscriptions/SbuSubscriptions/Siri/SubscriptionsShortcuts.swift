import AppIntents

/// The phrases Siri, Shortcuts, Spotlight and the Action button know, in Italian with English in AppShortcuts.xcstrings.
struct SubscriptionsShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: NextRenewalIntent(),
            phrases: [
                "Prossimo rinnovo in \(.applicationName)",
                "Quando si rinnova \(\.$subscription) in \(.applicationName)",
            ],
            shortTitle: "Prossimo rinnovo",
            systemImageName: "calendar.badge.clock"
        )
        AppShortcut(
            intent: MonthSpendingIntent(),
            phrases: ["Quanto pago questo mese con \(.applicationName)", "Spesa del mese in \(.applicationName)"],
            shortTitle: "Spesa del mese",
            systemImageName: "eurosign"
        )
        AppShortcut(
            intent: SubscriptionPriceIntent(),
            phrases: ["Quanto costa un abbonamento in \(.applicationName)", "Quanto costa \(\.$subscription) in \(.applicationName)"],
            shortTitle: "Prezzo",
            systemImageName: "tag"
        )
        AppShortcut(
            intent: SubscriptionCountIntent(),
            phrases: ["Quanti abbonamenti ho in \(.applicationName)"],
            shortTitle: "Quanti abbonamenti",
            systemImageName: "number"
        )
        AppShortcut(
            intent: OpenSubscriptionIntent(),
            phrases: ["Apri un abbonamento in \(.applicationName)", "Apri \(\.$target) in \(.applicationName)"],
            shortTitle: "Apri abbonamento",
            systemImageName: "creditcard"
        )
        AppShortcut(
            intent: OpenCalendarIntent(),
            phrases: ["Apri il calendario di \(.applicationName)"],
            shortTitle: "Calendario",
            systemImageName: "calendar"
        )
        AppShortcut(
            intent: AddSubscriptionIntent(),
            phrases: ["Aggiungi un abbonamento a \(.applicationName)"],
            shortTitle: "Aggiungi",
            systemImageName: "plus"
        )
    }
}
