import Foundation

/// When to ask for an App Store review: after the Closure on `daysNeeded` different days, at most
/// once per version, never at launch. Apple then decides whether the prompt appears, at most three
/// times a year.
nonisolated struct SbuReviewPrompt: Equatable, Sendable {
    static let daysNeeded = 3

    /// The days with a Closure since the last request, as `year-month-day`, oldest first.
    private(set) var days: [String] = []
    /// The version the review was last asked in.
    private(set) var askedVersion: String?

    /// Counts the day of a Closure; a second Closure on the same day counts once.
    mutating func recordClosure(on date: Date, calendar: Calendar = .current) {
        let parts = calendar.dateComponents([.year, .month, .day], from: date)
        let day = "\(parts.year ?? 0)-\(parts.month ?? 0)-\(parts.day ?? 0)"
        guard !days.contains(day) else { return }
        days = Array((days + [day]).suffix(Self.daysNeeded))
    }

    func shouldAsk(version: String) -> Bool {
        days.count >= Self.daysNeeded && askedVersion != version
    }

    /// Starts counting again: the next request needs a new version and new days.
    mutating func markAsked(version: String) {
        askedVersion = version
        days = []
    }
}

extension SbuReviewPrompt {
    private static let daysKey = "sbu.reviewPrompt.days"
    private static let versionKey = "sbu.reviewPrompt.askedVersion"

    init(defaults: UserDefaults) {
        days = defaults.stringArray(forKey: Self.daysKey) ?? []
        askedVersion = defaults.string(forKey: Self.versionKey)
    }

    func save(to defaults: UserDefaults) {
        defaults.set(days, forKey: Self.daysKey)
        defaults.set(askedVersion, forKey: Self.versionKey)
    }
}
