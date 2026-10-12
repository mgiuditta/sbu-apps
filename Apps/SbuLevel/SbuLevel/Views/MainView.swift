import SbuKit
import SwiftUI

/// The one screen: the angle in an `SbuStat`, the bubble or edge indicator, and Calibra.
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
        VStack(spacing: SbuTheme.space8) {
            SbuStat(
                "Inclinazione",
                value: model.reading.magnitude,
                format: .number.precision(.fractionLength(1)),
                unit: "°",
                context: context
            )

            LevelIndicator(reading: model.reading)
                .frame(maxWidth: 320)

            Spacer(minLength: 0)

            SbuButton("Calibra", action: model.calibrate)
                .disabled(model.isMotionAvailable == false)
        }
        .padding(SbuTheme.space4)
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
