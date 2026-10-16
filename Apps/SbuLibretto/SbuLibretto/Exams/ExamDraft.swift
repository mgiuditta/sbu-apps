import Foundation

/// What the exam form edits, as text and choices, until it is valid enough to save.
nonisolated struct ExamDraft: Equatable, Sendable {
    /// Why the draft cannot be saved yet.
    enum Problem: Equatable, Sendable {
        case missingName
        case missingCredits
        /// Not a number in the phone's language.
        case invalidCredits
        /// Zero, negative, or more than an exam can have.
        case creditsOutOfRange
        /// A grade from the future: an exam still to take has no grade.
        case futureDate
    }

    /// The credits an exam can have: 0.5 to 60, decimals allowed.
    static let creditsRange = 0.5...60.0
    static let courseYears = 1...6

    var name = ""
    var creditsText = ""
    var courseYear = 1
    var kind = ExamKind.graded
    /// Taken: with its grade, or passed for an idoneità. Not taken: still to take.
    var isTaken = true
    var mark = Grade.highest
    var cumLaude = false
    /// When it was taken, or the planned sitting.
    var date: Date
    /// For an exam still to take: whether the sitting has a date yet.
    var hasDate = true

    /// A new exam: taken today, or still to take with no date yet.
    init(isTaken: Bool, now: Date) {
        self.isTaken = isTaken
        date = now
        hasDate = isTaken
    }

    /// The draft of an exam already in the libretto.
    @MainActor
    init(exam: Exam, now: Date, locale: Locale) {
        name = exam.name
        creditsText = NumberText.text(exam.credits, fractionDigits: 0...2, locale: locale)
        courseYear = min(max(exam.courseYear, Self.courseYears.lowerBound), Self.courseYears.upperBound)
        kind = exam.kind
        isTaken = exam.result.isDone
        if let grade = exam.grade {
            mark = grade.mark
            cumLaude = grade.isCumLaude
        }
        date = exam.date ?? now
        hasDate = exam.date != nil
    }

    var trimmedName: String {
        name.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    /// The grade the draft would save, if it has one.
    var grade: Grade? {
        guard kind == .graded, isTaken else { return nil }
        return Grade(mark: mark, cumLaude: cumLaude && mark == Grade.highest)
    }

    func credits(locale: Locale) -> Double? {
        NumberText.double(creditsText, locale: locale)
    }

    /// The first thing that stops the draft from being saved, or `nil` when it can be.
    func problem(locale: Locale, now: Date, calendar: Calendar) -> Problem? {
        if trimmedName.isEmpty { return .missingName }
        if creditsText.trimmingCharacters(in: .whitespaces).isEmpty { return .missingCredits }
        guard let credits = credits(locale: locale), credits.isFinite else { return .invalidCredits }
        guard Self.creditsRange.contains(credits) else { return .creditsOutOfRange }
        if isTaken, let endOfToday = calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: now)), date >= endOfToday {
            return .futureDate
        }
        return nil
    }

    /// Writes the draft into an exam; call only when `problem` is `nil`.
    @MainActor
    func apply(to exam: Exam, locale: Locale) {
        exam.name = trimmedName
        exam.credits = credits(locale: locale) ?? exam.credits
        exam.courseYear = courseYear
        exam.kind = kind
        exam.grade = grade
        exam.isPassed = kind == .passFail && isTaken
        exam.date = isTaken || hasDate ? date : nil
    }
}
