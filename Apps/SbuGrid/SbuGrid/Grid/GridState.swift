import Foundation

/// Everything kept between launches besides the photo itself.
nonisolated struct GridState: Codable, Hashable, Sendable {
    var settings = GridSettings()

    init(settings: GridSettings = GridSettings()) {
        self.settings = settings
    }

    private enum CodingKeys: String, CodingKey {
        case settings
    }

    /// A part that no longer decodes takes its default, so the rest is never lost.
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        settings = (try? container.decodeIfPresent(GridSettings.self, forKey: .settings)) ?? GridSettings()
    }
}
