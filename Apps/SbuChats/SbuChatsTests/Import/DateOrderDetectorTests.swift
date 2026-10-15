import Foundation
import Testing
@testable import SbuChats

struct DateOrderDetectorTests {
    private func order(of lines: [String], preferring preferred: DateOrder = .dayMonthYear) -> DateOrder? {
        var detector = DateOrderDetector()
        for line in lines {
            if let header = WhatsAppLineScanner.header(of: line) { detector.add(header) }
        }
        return detector.order(preferring: preferred)
    }

    @Test func aDayAboveTwelveMeansDayFirst() {
        #expect(order(of: ["[1/2/24, 10:00:00] A: x", "[15/2/24, 10:00:00] A: y"], preferring: .monthDayYear) == .dayMonthYear)
    }

    @Test func aSecondFieldAboveTwelveMeansMonthFirst() {
        #expect(order(of: ["1/2/24, 10:00 - A: x", "1/13/24, 10:00 - A: y"]) == .monthDayYear)
    }

    @Test func aFourDigitFirstFieldMeansYearFirst() {
        #expect(order(of: ["[2024-01-02, 10:00:00] A: x"]) == .yearMonthDay)
    }

    @Test func chronologySettlesDatesThatFitBothWays() {
        // 1/2, 1/3, 1/4, 1/10, 2/1: in order as month-day, backwards once as day-month (1 Oct, then 2 Jan).
        let lines = ["[1/2/24, 10:00:00] A: x", "[1/3/24, 10:00:00] B: x", "[1/4/24, 10:00:00] A: x",
                     "[1/10/24, 10:00:00] B: x", "[2/1/24, 10:00:00] A: x"]
        #expect(order(of: lines, preferring: .dayMonthYear) == .monthDayYear)
    }

    @Test func aRealTieFollowsThePreferredOrder() {
        let lines = ["[1/1/24, 10:00:00] A: x", "[2/2/24, 10:00:00] B: x"]
        #expect(order(of: lines, preferring: .dayMonthYear) == .dayMonthYear)
        #expect(order(of: lines, preferring: .monthDayYear) == .monthDayYear)
    }

    @Test func datesNoOrderReadsHaveNoOrder() {
        #expect(order(of: ["[13/2/24, 10:00:00] A: x", "[2/13/24, 10:00:00] A: y"]) == nil)
    }

    @Test(arguments: [("it_IT", DateOrder.dayMonthYear), ("en_US", .monthDayYear), ("en_GB", .dayMonthYear), ("ja_JP", .yearMonthDay), ("de_DE", .dayMonthYear)])
    func preferredOrderFollowsTheLocale(identifier: String, expected: DateOrder) {
        #expect(DateOrderDetector.preferredOrder(for: Locale(identifier: identifier)) == expected)
    }
}
