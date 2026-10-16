import AppIntents

/// Siri and Shortcuts phrases, Italian source with English in AppShortcuts.xcstrings.
struct RemoteShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: VolumeUpIntent(),
            phrases: ["Alza il volume con \(.applicationName)", "Volume su con \(.applicationName)"],
            shortTitle: "Alza il volume",
            systemImageName: "speaker.plus"
        )
        AppShortcut(
            intent: VolumeDownIntent(),
            phrases: ["Abbassa il volume con \(.applicationName)", "Volume giù con \(.applicationName)"],
            shortTitle: "Abbassa il volume",
            systemImageName: "speaker.minus"
        )
        AppShortcut(
            intent: MuteIntent(),
            phrases: ["Silenzia la TV con \(.applicationName)"],
            shortTitle: "Silenzia",
            systemImageName: "speaker.slash"
        )
        AppShortcut(
            intent: PlayPauseIntent(),
            phrases: ["Metti in pausa la TV con \(.applicationName)", "Fai ripartire la TV con \(.applicationName)"],
            shortTitle: "Play o pausa",
            systemImageName: "playpause"
        )
        AppShortcut(
            intent: PowerIntent(),
            phrases: ["Accendi la TV con \(.applicationName)", "Spegni la TV con \(.applicationName)"],
            shortTitle: "Accensione",
            systemImageName: "power"
        )
    }
}
