import Foundation

/// The fingerprint of a message, the same in every export that contains it.
///
/// Time, author and text, plus how many identical messages came before it in the same file, so
/// two "ok" sent in the same minute stay two. Re-importing a newer export drops what's already
/// there by this value. FNV-1a, 64 bits: stable across launches, unlike `Hasher`.
nonisolated struct LineHash {
    private var occurrences: [UInt64: Int] = [:]

    /// The fingerprint of the next message of the file.
    mutating func next(for message: ParsedMessage) -> Int64 {
        let base = Self.fnv1a("\(Int64(message.sentAt.timeIntervalSince1970))\u{1F}\(message.sender ?? "")\u{1F}\(message.text)")
        let occurrence = occurrences[base, default: 0]
        occurrences[base] = occurrence + 1
        return Int64(bitPattern: Self.fnv1a("\(base)\u{1F}\(occurrence)"))
    }

    static func fnv1a(_ string: String) -> UInt64 {
        var hash: UInt64 = 0xCBF2_9CE4_8422_2325
        for byte in string.utf8 {
            hash ^= UInt64(byte)
            hash &*= 0x0000_0100_0000_01B3
        }
        return hash
    }
}
