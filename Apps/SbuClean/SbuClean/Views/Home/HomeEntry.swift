import SwiftUI

/// One way to clean on the home: where it leads, what it is, and the space it can free.
struct HomeEntry: Identifiable {
    let route: Route
    let title: LocalizedStringKey
    let subtitle: LocalizedStringKey
    let symbol: String
    /// The space behind the row; `nil` or zero shows no amount.
    var bytes: Int64?

    var id: String {
        route.identifier
    }
}
