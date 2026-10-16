import OSLog
import SwiftUI

extension View {
    /// In DEBUG, logs a warning when the view shows more than one `.set` full stop.
    /// The shells apply it to each screen they host.
    func sbuFullStopAudit(_ screen: String) -> some View {
        #if DEBUG
        onPreferenceChange(SbuSetFullStopCount.self) { count in
            SbuFullStopAuditLog.check(count, on: screen)
        }
        #else
        self
        #endif
    }
}

nonisolated enum SbuFullStopAuditLog {
    private static let logger = Logger(subsystem: "dev.sbu.SbuKit", category: "FullStop")

    static func check(_ count: Int, on screen: String) {
        guard !SbuSetFullStopCount.isAllowed(count) else { return }
        logger.warning("\(screen, privacy: .public) shows \(count) full stops in .set: the design system allows one per screen.")
    }
}
