import Foundation

/// Why an export did not happen.
nonisolated enum ExportError: Error, Equatable, Sendable {
    /// A PDF to scale needs a sheet.
    case noSheet
    /// The file could not be drawn or written.
    case notWritten
    /// Sbu Grid may not add to Photos: only Settings can change it.
    case photosDenied
    /// Photos refused the picture.
    case notSaved
}
