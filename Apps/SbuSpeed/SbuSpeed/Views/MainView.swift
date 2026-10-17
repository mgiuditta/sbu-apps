import AudioToolbox
import SbuKit
import SwiftUI
import UIKit

/// The tool screen: Velocità and the speed as the figure on the grid, Salva e azzera, Parabrezza,
/// the quick limits, and the trip in a card; Viaggi in the toolbar. In portrait the controls and the
/// card sit under the figure; in landscape, as in a car mount, beside it.
struct MainView: View {
    let model: SpeedModel

    @Environment(\.verticalSizeClass) private var verticalSizeClass
    @State private var isShowingHUD = false
    @State private var isClosing = false

    /// The system sound played once when the speed goes over the limit.
    private static let limitSound: SystemSoundID = 1005

    /// An iPhone on its side: little height, so the trip moves beside the figure.
    private var isLandscape: Bool { verticalSizeClass == .compact }

    private var readings: [SpeedReading] {
        SpeedReading.readings(trip: model.trip, navigation: model.navigation, unit: model.unit)
    }

    var body: some View {
        ZStack {
            // Parabrezza takes the place of the tool screen rather than covering it: one `.set` full
            // stop on screen, and the task below keeps reading the position while the HUD shows.
            if isShowingHUD {
                HUDView(model: model, exit: hideHUD)
            } else {
                toolScreen
            }
        }
        .toolbar(isShowingHUD ? .hidden : .automatic, for: .navigationBar)
        .statusBarHidden(isShowingHUD)
        .persistentSystemOverlays(isShowingHUD ? .hidden : .automatic)
        // A speedometer is read at a glance: the screen stays on while it is shown.
        .onAppear { UIApplication.shared.isIdleTimerDisabled = true }
        .onDisappear { UIApplication.shared.isIdleTimerDisabled = false }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                NavigationLink {
                    TripLogView(log: model.tripLog, unit: model.unit)
                } label: {
                    Label("Viaggi", systemImage: "list.bullet")
                }
            }
        }
        .sbuHaptic(.tick, trigger: model.limitAlerts)
        .onChange(of: model.limitAlerts, playLimitSound)
        .task {
            await model.run()
        }
    }

    /// One tree for both orientations: turning the iPhone keeps the field and its open dialog.
    private var toolScreen: some View {
        GeometryReader { geometry in
            ScrollView {
                content
                    .padding(SbuTheme.space4)
                    .frame(maxWidth: .infinity, minHeight: geometry.size.height, alignment: .topLeading)
                    // Inside the scroll content, so the grid and the figure's baseline move together.
                    .sbuPaper(grid: true)
            }
            .scrollBounceBehavior(.basedOnSize)
        }
        .background(SbuTheme.paper)
    }

    private var layout: AnyLayout {
        isLandscape
            ? AnyLayout(HStackLayout(alignment: .top, spacing: SbuTheme.space6))
            : AnyLayout(VStackLayout(alignment: .leading, spacing: SbuTheme.space6))
    }

    /// In landscape the figure has the left column to itself, the hero size needs the whole height,
    /// and the title and the controls head the column beside it, so they stay on screen.
    private var content: some View {
        VStack(alignment: .leading, spacing: SbuTheme.space6) {
            if !isLandscape {
                SpeedTitle(model: model)
            }

            layout {
                SpeedToolField(model: model, isClosing: $isClosing)

                VStack(alignment: .leading, spacing: SbuTheme.space6) {
                    if isLandscape {
                        SpeedTitle(model: model)
                    }
                    SpeedControls(model: model, showHUD: showHUD, didSaveTrip: close)
                    ReadingsCard(readings: readings)
                }
            }
        }
    }

    private func showHUD() {
        isShowingHUD = true
    }

    private func hideHUD() {
        isShowingHUD = false
    }

    private func close() {
        isClosing = true
    }

    private func playLimitSound() {
        AudioServicesPlaySystemSound(Self.limitSound)
    }
}

#Preview("Light") {
    NavigationStack {
        MainView(model: SpeedModel())
    }
    .environment(\.sbuAccent, .speed)
}

#Preview("Dark") {
    NavigationStack {
        MainView(model: SpeedModel())
    }
    .environment(\.sbuAccent, .speed)
    .preferredColorScheme(.dark)
}

#Preview("Landscape", traits: .landscapeLeft) {
    NavigationStack {
        MainView(model: SpeedModel())
    }
    .environment(\.sbuAccent, .speed)
}
