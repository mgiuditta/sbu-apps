import Foundation

/// A filter you can switch off for one Platform in Impostazioni, as in SocialLite's sheet per
/// platform: what it adds to the Platform's rules while it is on.
nonisolated struct PlatformOption: Codable, Hashable, Identifiable {
    let id: String
    /// The Italian name, the key of its translation in the string catalog.
    let title: String
    var defaultOn = true
    var blockedPaths: [String] = []
    var hiddenLabels: [String] = []
    var css = ""
    /// A switch the Platform's own script reads, such as `ads`.
    var flag: String?

    enum CodingKeys: String, CodingKey {
        case id, title, defaultOn, blockedPaths, hiddenLabels, css, flag
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        defaultOn = try container.decodeIfPresent(Bool.self, forKey: .defaultOn) ?? true
        blockedPaths = try container.decodeIfPresent([String].self, forKey: .blockedPaths) ?? []
        hiddenLabels = try container.decodeIfPresent([String].self, forKey: .hiddenLabels) ?? []
        css = try container.decodeIfPresent(String.self, forKey: .css) ?? ""
        flag = try container.decodeIfPresent(String.self, forKey: .flag)
    }
}
