import Foundation

/// Gives the iPhone's position once: Core Location in the app, a stand-in in tests.
protocol LocationProviding {
    /// Asks for when-in-use access if it was never asked, then reads one position.
    func currentCoordinates() async throws -> Coordinates
}
