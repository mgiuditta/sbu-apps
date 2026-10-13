import Foundation

/// What a swipe in Timer asks to delete, before the confirmation.
nonisolated enum Deletion: Equatable, Sendable {
    case timer(SoundTimer.ID)
    case alarm(SoundAlarm.ID)
}
