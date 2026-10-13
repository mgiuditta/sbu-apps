import SwiftUI

/// The label of the bottom action that sends a selection to the bin: "Elimina 1,2 GB", or
/// just "Elimina" while nothing is selected.
enum DeleteTitle {
    static func forBytes(_ bytes: Int64) -> LocalizedStringKey {
        guard bytes > 0 else { return "Elimina" }

        let figure = SpaceFigure(bytes: bytes)
        return "Elimina \(figure.formattedValue) \(figure.unit)"
    }
}
