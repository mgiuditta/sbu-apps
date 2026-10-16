import Foundation

extension ShrinkModel {
    /// A model on the demo library and compressor, with `videos` demo videos already picked.
    static func preview(videos: Int = 0, scenario: String? = nil, access: LibraryAccess = .full) -> ShrinkModel {
        let model = ShrinkModel(
            compressor: DemoCompressor(),
            library: DemoLibrary(access: access),
            preferences: Preferences(defaults: UserDefaults(suiteName: "preview") ?? .standard),
            probe: DemoVideos.probe
        )
        let names = DemoVideos.names(count: videos, scenario: scenario)
        if !names.isEmpty {
            model.pick(names.map { DemoVideos.pending($0) })
        }
        return model
    }
}
