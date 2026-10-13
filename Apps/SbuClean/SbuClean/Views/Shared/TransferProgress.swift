import Observation

/// How far a download or a compression got, updated from any thread.
@Observable
final class TransferProgress {
    var fraction: Double = 0
    /// Whether the original is still coming down from iCloud.
    var isDownloading = false

    /// Hands a download fraction reported off the main actor to the screen.
    nonisolated func report(_ fraction: Double) {
        Task { @MainActor in
            self.fraction = fraction
        }
    }

    /// Hands a compression step reported off the main actor to the screen.
    nonisolated func report(_ step: CompressionStep) {
        Task { @MainActor in
            switch step {
            case .downloading(let fraction):
                self.isDownloading = true
                self.fraction = fraction
            case .compressing(let fraction):
                self.isDownloading = false
                self.fraction = fraction
            }
        }
    }

    func reset() {
        fraction = 0
        isDownloading = false
    }
}
