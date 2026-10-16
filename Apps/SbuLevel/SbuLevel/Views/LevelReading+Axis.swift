import Foundation

extension LevelReading {
    /// What the figure is measuring, for the cartiglio: the surface, the long or short edge, or
    /// the line of sight.
    var axisName: LocalizedStringResource {
        switch mode {
        case .flat: "In piano"
        case .sight: "Linea di mira"
        case .edge: edge == .left || edge == .right ? "Asse lungo" : "Asse corto"
        }
    }
}
