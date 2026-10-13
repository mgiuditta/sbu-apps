import Foundation

/// What a calibration applies to: the bubble level lying flat, or one edge of the clinometer.
nonisolated enum CalibrationTarget: Hashable, Sendable, CaseIterable {
    case flat
    case edge(Edge)

    static let allCases: [CalibrationTarget] = [.flat] + Edge.allCases.map(CalibrationTarget.edge)

    /// Name of the side, for settings and the calibration sheet.
    var name: LocalizedStringResource {
        switch self {
        case .flat: "Piano"
        case .edge(.bottom): "Bordo inferiore"
        case .edge(.right): "Bordo destro"
        case .edge(.top): "Bordo superiore"
        case .edge(.left): "Bordo sinistro"
        }
    }
}
