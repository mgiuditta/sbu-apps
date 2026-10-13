import Foundation

/// Why the iPhone's position could not be read.
nonisolated enum LocationError: Error, Equatable {
    /// Location is off for Sbu Moon, or for the whole iPhone.
    case denied
    /// No position came, such as indoors without Wi-Fi.
    case unavailable
}
