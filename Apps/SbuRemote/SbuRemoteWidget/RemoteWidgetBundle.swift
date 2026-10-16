import SwiftUI
import WidgetKit

@main
struct RemoteWidgetBundle: WidgetBundle {
    var body: some Widget {
        RemoteWidget()
        if #available(iOS 18, *) {
            PowerControl()
        }
    }
}
