/// Where the iPhone is, for the sightings: Core Location on an iPhone, a fixed place in the
/// simulator, UI tests and previews.
protocol LocationProvider: AnyObject {
    /// The latest position, or `nil` before the first fix or without permission.
    var current: Coordinate? { get }

    /// Asks for location while the app is in use, the first time; `false` if not allowed.
    func requestAccess() async -> Bool

    /// Starts following the position while the app is open.
    func start()

    func stop()
}
