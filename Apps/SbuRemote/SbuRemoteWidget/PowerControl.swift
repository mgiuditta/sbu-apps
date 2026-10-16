import AppIntents
import SwiftUI
import WidgetKit

/// The TV's power key in Control Center, on the Lock Screen and on the Action button (iOS 18).
@available(iOS 18, *)
struct PowerControl: ControlWidget {
    var body: some ControlWidgetConfiguration {
        StaticControlConfiguration(kind: "dev.sbu.remote.power") {
            ControlWidgetButton(action: PowerIntent()) {
                Label("Accensione TV", systemImage: "power")
            }
        }
        .displayName("Accensione TV")
        .description("Accende o spegne l'ultima TV usata in Sbu Remote.")
    }
}
