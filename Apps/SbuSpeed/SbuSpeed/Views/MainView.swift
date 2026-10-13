import AudioToolbox
import SbuKit
import SwiftUI
import UIKit

/// The tool screen: the speed as the figure, the dial, the trip, and Azzera viaggio.
/// In portrait the trip sits under the dial; in landscape, as in a car mount, it sits beside the figure.
struct MainView: View {
    let model: SpeedModel

    @Environment(\.verticalSizeClass) private var verticalSizeClass
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    /// The system sound played once when the speed goes over the limit.
    private static let limitSound: SystemSoundID = 1005

    /// An iPhone on its side: little height, so the trip moves beside the figure.
    private var isLandscape: Bool { verticalSizeClass == .compact }

    var body: some View {
        Group {
            // At accessibility text sizes the screen is not tall enough: then everything scrolls.
            if dynamicTypeSize.isAccessibilitySize {
                ScrollView {
                    layout
                }
            } else {
                layout
            }
        }
        // A speedometer is read at a glance: the screen stays on while it is shown.
        .onAppear { UIApplication.shared.isIdleTimerDisabled = true }
        .onDisappear { UIApplication.shared.isIdleTimerDisabled = false }
        .sensoryFeedback(.warning, trigger: model.limitAlerts)
        .onChange(of: model.limitAlerts, playLimitSound)
        .task {
            await model.run()
        }
    }

    /// One tree for both orientations: turning the iPhone keeps the field and its open dialog.
    private var layout: some View {
        HStack(spacing: 0) {
            SpeedToolField(model: model) {
                if !isLandscape {
                    // First call on the height left: the dial grows to its full size before the gap above the pills.
                    DialAndTrip(model: model)
                        .layoutPriority(1)
                }
            }

            if isLandscape {
                DialAndTrip(model: model)
                    .padding(SbuTheme.space4)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }

    private func playLimitSound() {
        AudioServicesPlaySystemSound(Self.limitSound)
    }
}

#Preview("Light") {
    MainView(model: SpeedModel())
        .background(SbuTheme.surface)
        .tint(SbuTheme.accentSpeed)
}

#Preview("Dark") {
    MainView(model: SpeedModel())
        .background(SbuTheme.surface)
        .tint(SbuTheme.accentSpeed)
        .preferredColorScheme(.dark)
}

#Preview("Landscape", traits: .landscapeLeft) {
    MainView(model: SpeedModel())
        .background(SbuTheme.surface)
        .tint(SbuTheme.accentSpeed)
}
