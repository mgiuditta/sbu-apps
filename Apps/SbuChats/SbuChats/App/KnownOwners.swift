import Foundation

/// The names you said were you, so the next chat with one of them doesn't ask again.
///
/// Only names, on this iPhone, in the app's defaults; forgetting one asks again next time.
struct KnownOwners {
    private static let key = "knownOwners"
    private let defaults: UserDefaults

    init(defaults: UserDefaults) {
        self.defaults = defaults
    }

    /// The names, in the order you gave them.
    var names: [String] {
        defaults.stringArray(forKey: Self.key) ?? []
    }

    func remember(_ name: String) {
        guard !names.contains(name) else { return }
        defaults.set(names + [name], forKey: Self.key)
    }

    func forget(_ name: String) {
        defaults.set(names.filter { $0 != name }, forKey: Self.key)
    }
}
