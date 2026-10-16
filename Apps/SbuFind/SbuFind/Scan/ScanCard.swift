import Foundation

/// When the "Ricerca…" card shows at the bottom of the list, as Find Air's scanning sheet does:
/// at every scan start, until you close it, or by itself once devices have been heard for a while.
nonisolated struct ScanCard: Equatable, Sendable {
    /// How long the card stays once there is something in the list.
    static let autoHideAfter: TimeInterval = 8

    private(set) var isVisible = false
    private var shownAt: Date?

    /// A scan starts: at launch, or with Cerca di nuovo.
    mutating func show(at now: Date) {
        isVisible = true
        shownAt = now
    }

    /// The close button.
    mutating func close() {
        isVisible = false
        shownAt = nil
    }

    /// Hides the card once devices are listed and it has been up for `autoHideAfter`.
    mutating func update(at now: Date, listedDevices: Int) {
        guard isVisible, let shownAt, listedDevices > 0 else { return }
        if now.timeIntervalSince(shownAt) >= Self.autoHideAfter {
            close()
        }
    }
}
