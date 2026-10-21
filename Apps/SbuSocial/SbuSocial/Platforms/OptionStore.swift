import Foundation
import Observation

/// Which filters are on for each Platform, and the Platform opened at launch, kept in UserDefaults.
@Observable
final class OptionStore {
    private var enabled: [Platform: Set<String>]
    /// Opened straight away when the app starts, as in SocialLite; `nil` opens Home.
    var launchPlatform: Platform? {
        didSet { defaults.set(launchPlatform?.rawValue, forKey: "launchPlatform") }
    }

    @ObservationIgnored private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        enabled = defaults.data(forKey: "options").flatMap { try? JSONDecoder().decode([Platform: Set<String>].self, from: $0) }
            ?? Dictionary(uniqueKeysWithValues: Platform.allCases.map { platform in
                (platform, Set(platform.rules.options.filter(\.defaultOn).map(\.id)))
            })
        launchPlatform = defaults.string(forKey: "launchPlatform").flatMap(Platform.init(rawValue:))
    }

    func isOn(_ option: PlatformOption, on platform: Platform) -> Bool {
        enabled[platform, default: []].contains(option.id)
    }

    func set(_ option: PlatformOption, on platform: Platform, to isOn: Bool) {
        if isOn { enabled[platform, default: []].insert(option.id) } else { enabled[platform, default: []].remove(option.id) }
        defaults.set(try? JSONEncoder().encode(enabled), forKey: "options")
    }

    /// The Platform's rules with its filters as you set them.
    func rules(for platform: Platform) -> PlatformRules {
        platform.rules.applying(enabled: enabled[platform, default: []])
    }
}
