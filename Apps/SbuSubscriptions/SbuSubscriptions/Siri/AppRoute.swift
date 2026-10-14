import Foundation
import Observation

/// Where Siri, Shortcuts or Spotlight asked the app to go.
enum AppRoute: Equatable {
    case subscription(UUID)
    case calendar
    case add
}

/// Holds the latest route until the home is on screen to follow it: an intent can run on a cold launch,
/// before any view exists.
@Observable
final class AppRouter {
    var pending: AppRoute?

    func open(_ route: AppRoute) {
        pending = route
    }
}
