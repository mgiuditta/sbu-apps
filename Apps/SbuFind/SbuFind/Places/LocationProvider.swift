/// Where the iPhone is, for the sightings: Core Location on an iPhone, a fixed place in the
/// simulator, UI tests and previews.
protocol LocationProvider: AnyObject {
    /// The latest position, or `nil` before the first fix or without permission.
    var current: Coordinate? { get }

    /// Whether a position can be read with the app in the background: location "Sempre".
    var allowsBackground: Bool { get }

    /// Asks for location while the app is in use, the first time; `false` if not allowed.
    func requestAccess() async -> Bool

    /// Asks to read the position also with the app in the background ("Sempre"); only when you
    /// turn that on. `false` if not allowed.
    func requestBackgroundAccess() async -> Bool

    /// Starts following the position while the app is open.
    func start()

    func stop()

    /// One position now, for a device heard with the app in the background; `nil` without one.
    func oneShot() async -> Coordinate?
}
