import Foundation

/// The iPhone's capacity and what is free, as Settings shows it.
nonisolated struct DeviceStorage: Equatable, Sendable {
    var totalBytes: Int64
    var availableBytes: Int64

    var usedBytes: Int64 {
        max(totalBytes - availableBytes, 0)
    }

    var usedFraction: Double {
        totalBytes > 0 ? Double(usedBytes) / Double(totalBytes) : 0
    }

    /// Reads the volume of the app's home folder; `nil` when the system does not say.
    static func current() -> DeviceStorage? {
        let values = try? URL.homeDirectory.resourceValues(forKeys: [.volumeTotalCapacityKey, .volumeAvailableCapacityForImportantUsageKey])
        guard let total = values?.volumeTotalCapacity, let available = values?.volumeAvailableCapacityForImportantUsage else { return nil }

        return DeviceStorage(totalBytes: Int64(total), availableBytes: available)
    }
}
