/// The order of day, month and year in an export's dates.
nonisolated enum DateOrder: String, CaseIterable, Sendable {
    case dayMonthYear
    case monthDayYear
    case yearMonthDay

    /// Day, month and year from the three numbers as written; two-digit years are 20xx.
    func components(of fields: [Int]) -> (year: Int, month: Int, day: Int) {
        let (year, month, day) = switch self {
        case .dayMonthYear: (fields[2], fields[1], fields[0])
        case .monthDayYear: (fields[2], fields[0], fields[1])
        case .yearMonthDay: (fields[0], fields[1], fields[2])
        }
        return (year < 100 ? 2000 + year : year, month, day)
    }

    /// Whether the three numbers make a plausible date in this order.
    func accepts(_ fields: [Int]) -> Bool {
        let date = components(of: fields)
        return (1 ... 12).contains(date.month) && (1 ... 31).contains(date.day)
    }
}
