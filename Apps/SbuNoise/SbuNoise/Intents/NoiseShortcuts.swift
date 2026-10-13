import AppIntents

/// Riproduci and Metti in pausa in Comandi rapidi, Siri, Spotlight and the Action button.
struct NoiseShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: PlaySoundIntent(),
            phrases: [
                "Riproduci \(.applicationName)",
                "Avvia \(.applicationName)",
                "Riproduci \(\.$sound) con \(.applicationName)",
            ],
            shortTitle: "Riproduci",
            systemImageName: "play.fill"
        )
        AppShortcut(
            intent: PauseSoundIntent(),
            phrases: [
                "Metti in pausa \(.applicationName)",
                "Ferma \(.applicationName)",
            ],
            shortTitle: "Metti in pausa",
            systemImageName: "pause.fill"
        )
    }
}
