/// The start of a message line in an export, before the date order is known.
///
/// The three date numbers stay as written: whether `15/10/26` is day-month-year or `10/15/26`
/// month-day-year is decided once for the whole file by `DateOrderDetector`.
nonisolated struct MessageHeader: Equatable, Sendable {
    /// How the line frames the timestamp.
    enum Style: String, Equatable, Sendable {
        /// iPhone: `[15/10/26, 18:30:12] Name: text`.
        case bracketed
        /// Android: `15/10/26, 18:30 - Name: text`.
        case dashed
    }

    /// Morning or afternoon on a 12-hour clock.
    enum Meridiem: Equatable, Sendable {
        case am
        case pm
    }

    let style: Style
    /// The three date numbers in the order they appear.
    let dateFields: [Int]
    /// How many digits the first date number had: four means year first.
    let firstFieldDigits: Int
    let hour: Int
    let minute: Int
    let second: Int
    let meridiem: Meridiem?
    /// The author, or `nil` for a line the app itself wrote (a system message on Android).
    let sender: String?
    /// The text after the author, as written.
    let body: String
}
