import Foundation

/// How the photo shows over the camera while tracing: see-through enough to see the pencil on
/// the paper, solid enough to see the lines to follow.
nonisolated struct TraceSettings: Codable, Hashable, Sendable {
    /// Never fully clear nor fully solid: either would hide what you trace or what you trace on.
    static let opacityRange: ClosedRange<Double> = 0.05...0.95
    static let opacityStep = 0.05

    private var storedOpacity = 0.5

    init() {}

    /// The photo's opacity over the camera.
    var photoOpacity: Double {
        get { storedOpacity }
        set { storedOpacity = GridSettings.clamp(newValue, to: Self.opacityRange) }
    }

    private enum CodingKeys: String, CodingKey {
        case photoOpacity
    }

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        photoOpacity = (try? container.decodeIfPresent(Double.self, forKey: .photoOpacity)) ?? TraceSettings().photoOpacity
    }

    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(photoOpacity, forKey: .photoOpacity)
    }
}
