import Foundation

extension Sound {
    /// Tones made for waking up, offered first for an alarm next to the whole catalog. They are
    /// not in the player.
    nonisolated static let alarmTones: [Sound] = [
        Sound(id: "alarm.chimes", name: "Rintocchi", systemImage: "bell", category: .home, source: .loop("alarm.chimes", credit: nil)),
        Sound(id: "alarm.beeps", name: "Sveglia classica", systemImage: "alarm", category: .home, source: .loop("alarm.beeps", credit: nil)),
    ]

    /// The backup notification's sound: the Rintocchi, under 30 seconds, in IMA4 as iOS asks.
    nonisolated static let alarmNotificationSoundName = "alarm.notification.caf"
}
