import Foundation

/// Decides when to read the figure aloud: fed every reading, it answers with the words to say, or `nil`.
nonisolated struct SpeechSchedule: Equatable, Sendable {
    /// Seconds the reading must hold before it is read in `whenSettled`.
    static let settleTime = 1.0
    /// Degrees the reading may wander and still count as settled.
    static let settleTolerance = 0.3
    /// Seconds between readings in `interval`.
    static let interval = 3.0

    var mode: SpeechMode

    private var anchor: Double?
    private var anchorTime = 0.0
    private var lastSpoken: String?
    private var lastSpokenTime: Double?

    init(mode: SpeechMode) {
        self.mode = mode
    }

    /// - Parameters:
    ///   - degrees: The angle the figure shows, in degrees.
    ///   - text: The figure in words.
    ///   - time: Seconds on a steady clock.
    /// - Returns: The words to say now, if any.
    mutating func next(degrees: Double, text: String, at time: Double) -> String? {
        switch mode {
        case .off:
            return nil
        case .interval:
            if let lastSpokenTime, time - lastSpokenTime < Self.interval { return nil }
            return speak(text, at: time)
        case .whenSettled:
            guard let anchor, abs(degrees - anchor) <= Self.settleTolerance else {
                anchor = degrees
                anchorTime = time
                return nil
            }
            guard time - anchorTime >= Self.settleTime, text != lastSpoken else { return nil }
            return speak(text, at: time)
        }
    }

    private mutating func speak(_ text: String, at time: Double) -> String {
        lastSpoken = text
        lastSpokenTime = time
        return text
    }
}
