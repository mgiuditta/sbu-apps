import Foundation
import Observation

/// The course you set in Settings: optional names, and the rules for the averages and the base.
/// Saved on the device as you change them.
@Observable
final class CourseSettings {
    enum Key {
        static let rules = "course.rules"
        static let university = "course.university"
        static let course = "course.name"
    }

    /// Always sanitized: what is saved and used is within range.
    var rules: GradeRules {
        didSet {
            let clean = rules.sanitized
            if clean != rules {
                rules = clean
                return
            }
            if let data = try? JSONEncoder().encode(rules) { defaults.set(data, forKey: Key.rules) }
        }
    }
    var university: String {
        didSet { defaults.set(university, forKey: Key.university) }
    }
    var course: String {
        didSet { defaults.set(course, forKey: Key.course) }
    }

    @ObservationIgnored private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        let saved = defaults.data(forKey: Key.rules).flatMap { try? JSONDecoder().decode(GradeRules.self, from: $0) }
        rules = (saved ?? .standard).sanitized
        university = defaults.string(forKey: Key.university) ?? ""
        course = defaults.string(forKey: Key.course) ?? ""
    }
}
