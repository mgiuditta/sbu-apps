import Foundation

/// Where a sound's audio comes from.
nonisolated enum SoundSource: Hashable, Sendable {
    /// Computed while it plays, forever, with no loop.
    case generated(NoiseColor)
    /// A loop in the app bundle, `Sounds/<name>.caf`, crossfaded at the seam when it was made.
    case loop(String, credit: SoundCredit?)

    var isLoop: Bool {
        if case .loop = self { true } else { false }
    }

    /// The loop file in the bundle; `nil` for a generated noise.
    var url: URL? {
        guard case .loop(let name, _) = self else { return nil }
        return Bundle.main.url(forResource: name, withExtension: "caf")
    }

    /// The recording's author and licence; `nil` for sounds made by Sbu Noise.
    var credit: SoundCredit? {
        guard case .loop(_, let credit) = self else { return nil }
        return credit
    }
}
