nonisolated extension Character {
    /// Whether this grapheme is an emoji as people see it, with its skin tone, joiners and flags.
    ///
    /// Digits, `#` and `©` have the emoji property too but show as text unless a variation
    /// selector or keycap follows: only those combinations count.
    var isEmoji: Bool {
        guard let first = unicodeScalars.first else { return false }
        if first.properties.isEmojiPresentation { return true }
        guard first.properties.isEmoji, unicodeScalars.count > 1 else { return false }
        return unicodeScalars.contains { scalar in
            scalar.value == 0xFE0F || scalar.value == 0x200D || scalar.value == 0x20E3 || (0x1F3FB ... 0x1F3FF).contains(scalar.value)
        }
    }
}
