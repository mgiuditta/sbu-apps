import SbuKit
import SwiftUI

/// The tool screen: the angle as the figure, the bubble or edge indicator, and Calibra.
struct MainView: View {
    let model: LevelModel

    private var context: LocalizedStringKey {
        if model.isMotionAvailable == false {
            "Sensore di movimento non disponibile"
        } else if model.reading.isLevel {
            "In bolla"
        } else if model.reading.mode == .flat {
            "In piano"
        } else {
            "Sul bordo"
        }
    }

    var body: some View {
        SbuToolField(
            "Inclinazione",
            value: model.reading.magnitude,
            format: .number.precision(.fractionLength(1)),
            unit: "°",
            context: context
        ) {
            LevelIndicator(reading: model.reading)
                .frame(maxWidth: 320)
        } pills: {
            Button("Calibra", action: model.calibrate)
                .buttonStyle(SbuFieldPillStyle())
                .disabled(model.isMotionAvailable == false)
        }
        .sensoryFeedback(.success, trigger: model.reading.isLevel) { _, isLevel in isLevel }
        .task {
            await model.run()
        }
    }
}

#Preview("Light") {
    MainView(model: LevelModel())
        .background(SbuTheme.surface)
        .tint(SbuTheme.accentLevel)
}

#Preview("Dark") {
    MainView(model: LevelModel())
        .background(SbuTheme.surface)
        .tint(SbuTheme.accentLevel)
        .preferredColorScheme(.dark)
}
