import Observation
import WidgetKit

/// Keeps the widgets and the control on the player: writes `NowPlaying` to the App Group each
/// time the sound or play/pause changes, then asks them to reload. Created once at launch.
final class WidgetSync {
    private let model: PlayerModel
    private let url: URL
    private var saved: NowPlaying?

    init(model: PlayerModel, url: URL = NowPlaying.url) {
        self.model = model
        self.url = url
        observe()
    }

    private func observe() {
        let now = withObservationTracking {
            NowPlaying(model.current, isPlaying: model.isPlaying)
        } onChange: { [weak self] in
            Task { @MainActor in self?.observe() }
        }
        guard now != saved else { return }
        saved = now
        try? now.save(to: url)
        WidgetCenter.shared.reloadTimelines(ofKind: NowPlaying.widgetKind)
        if #available(iOS 18, *) {
            ControlCenter.shared.reloadControls(ofKind: NowPlaying.controlKind)
        }
    }
}

extension NowPlaying {
    init(_ item: PlayerItem?, isPlaying: Bool) {
        self.init(name: item?.name, systemImage: item?.systemImage, isPlaying: isPlaying)
    }
}
