import SwiftUI

/// The tone of a status word under a figure. Always paired with text, never color alone.
public enum SbuStatusTone: Sendable {
    /// Nothing to report, in `inkMuted`.
    case neutral
    /// Something is coming up soon, in `warning`.
    case warning
    /// Done or successful, in `success`.
    case success

    var color: Color {
        switch self {
        case .neutral: SbuTheme.inkMuted
        case .warning: SbuTheme.warning
        case .success: SbuTheme.success
        }
    }
}
