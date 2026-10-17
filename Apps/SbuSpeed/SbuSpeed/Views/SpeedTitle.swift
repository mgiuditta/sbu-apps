import SbuKit
import SwiftUI

/// The title of the tool screen, Velocità (SOG with knots), and its cartiglio: unit and GPS accuracy.
struct SpeedTitle: View {
    let model: SpeedModel

    /// With knots the speed is SOG, speed over ground, as on a chart plotter.
    private var caption: String {
        model.unit == .knots ? String(localized: "SOG") : String(localized: "Velocità")
    }

    private var cartiglio: String {
        ["Sbu", String(localized: "Velocità"), model.unit.symbol, String(localized: model.gpsAccuracy.text)]
            .joined(separator: " · ")
    }

    var body: some View {
        SbuScreenTitle(verbatim: caption, cartiglio: cartiglio)
    }
}

#Preview("Light") {
    SpeedTitle(model: SpeedModel())
        .padding(SbuTheme.space4)
        .frame(maxHeight: .infinity, alignment: .top)
        .sbuPaper()
}

#Preview("Dark") {
    SpeedTitle(model: SpeedModel())
        .padding(SbuTheme.space4)
        .frame(maxHeight: .infinity, alignment: .top)
        .sbuPaper()
        .preferredColorScheme(.dark)
}
