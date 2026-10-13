/// How a habit's notifications come: through a Focus or not, with which sound, and whether a
/// word comes when Salute marks it done.
nonisolated struct NotificationStyle: Hashable, Codable, Sendable {
    /// Time Sensitive: the reminders can come through a Focus that allows them.
    var isTimeSensitive: Bool
    var sound: ReminderSound
    /// "<Titolo>: fatta" when Salute marks it done by itself; only for a habit linked to Salute.
    var announcesHealthMark: Bool

    init(isTimeSensitive: Bool = false, sound: ReminderSound = .standard, announcesHealthMark: Bool = false) {
        self.isTimeSensitive = isTimeSensitive
        self.sound = sound
        self.announcesHealthMark = announcesHealthMark
    }

    // Every field optional; a sound this version does not know plays iOS's own.
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        isTimeSensitive = try container.decodeIfPresent(Bool.self, forKey: .isTimeSensitive) ?? false
        sound = (try? container.decodeIfPresent(ReminderSound.self, forKey: .sound)) ?? .standard
        announcesHealthMark = try container.decodeIfPresent(Bool.self, forKey: .announcesHealthMark) ?? false
    }
}
