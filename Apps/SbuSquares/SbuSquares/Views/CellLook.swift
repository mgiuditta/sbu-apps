import SwiftUI

/// How one board cell is drawn.
enum CellLook: Hashable {
    case empty
    case filled(Color)
    /// Empty, where the dragged piece would land, in its color.
    case shadow(Color)
    /// In a line the dragged piece would complete: in the dragged piece's color.
    case completing(Color)
}
