import AppIntents

/// Scansiona in Comandi rapidi, Siri, Spotlight and the Action button.
struct ScannerShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: ScanCodeIntent(),
            phrases: [
                "Scansiona con \(.applicationName)",
                "Leggi un codice con \(.applicationName)",
                "Apri \(.applicationName)",
            ],
            shortTitle: "Scansiona",
            systemImageName: "qrcode.viewfinder"
        )
    }
}
