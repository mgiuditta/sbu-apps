import Foundation

/// What the player shows and whether it plays, as the widgets and the control draw it. The app
/// writes it to the App Group each time it changes; the widget extension only reads it.
nonisolated struct NowPlaying: Codable, Equatable, Sendable {
    static let widgetKind = "dev.sbu.noise.now-playing"
    static let controlKind = "dev.sbu.noise.playback"

    /// The sound's or mix's name; `nil` in an empty category.
    var name: String?
    var systemImage: String?
    var isPlaying = false

    /// What a widget shows before the app has ever run, and in the gallery.
    static let sample = NowPlaying(name: String(localized: "Rumore rosa"), systemImage: "waveform.path")

    /// The file in the App Group container.
    static var url: URL {
        AppGroup.folder.appending(path: "now-playing.json")
    }

    /// The saved state, or a paused player with nothing chosen if there is none.
    static func load(from url: URL = url) -> NowPlaying {
        (try? Data(contentsOf: url)).flatMap { try? JSONDecoder().decode(NowPlaying.self, from: $0) } ?? NowPlaying()
    }

    func save(to url: URL = Self.url) throws {
        try FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
        try JSONEncoder().encode(self).write(to: url, options: .atomic)
    }
}
