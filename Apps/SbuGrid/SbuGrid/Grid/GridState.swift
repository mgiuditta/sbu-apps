import CoreGraphics
import Foundation

/// Everything kept between launches besides the photo itself.
nonisolated struct GridState: Codable, Hashable, Sendable {
    var settings = GridSettings()
    var paper = PaperSettings()
    /// The crop of the photo in unit coordinates; `nil` for the whole photo.
    var crop: CGRect?
    var trace = TraceSettings()

    init(settings: GridSettings = GridSettings(), paper: PaperSettings = PaperSettings(), crop: CGRect? = nil, trace: TraceSettings = TraceSettings()) {
        self.settings = settings
        self.paper = paper
        self.crop = crop
        self.trace = trace
    }

    private enum CodingKeys: String, CodingKey {
        case settings, paper, crop, trace
    }

    /// A part that no longer decodes takes its default, so the rest is never lost; a crop that
    /// no longer makes sense is the whole photo.
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        settings = (try? container.decodeIfPresent(GridSettings.self, forKey: .settings)) ?? GridSettings()
        paper = (try? container.decodeIfPresent(PaperSettings.self, forKey: .paper)) ?? PaperSettings()
        crop = ((try? container.decodeIfPresent(CGRect.self, forKey: .crop)) ?? nil).flatMap(CropGeometry.sanitized)
        trace = (try? container.decodeIfPresent(TraceSettings.self, forKey: .trace)) ?? TraceSettings()
    }

    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(settings, forKey: .settings)
        try container.encode(paper, forKey: .paper)
        try container.encodeIfPresent(crop, forKey: .crop)
        try container.encode(trace, forKey: .trace)
    }
}
