import SwiftUI
import WidgetKit

@main
struct NoiseWidgetBundle: WidgetBundle {
    var body: some Widget {
        NowPlayingWidget()
        if #available(iOS 18, *) {
            PlaybackControl()
        }
    }
}
