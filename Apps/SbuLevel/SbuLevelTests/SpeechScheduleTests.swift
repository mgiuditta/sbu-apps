import Testing
@testable import SbuLevel

struct SpeechScheduleTests {
    /// Feeds `degrees` 30 times a second from `from` to `to` seconds; returns what was said.
    private func feed(_ schedule: inout SpeechSchedule, degrees: Double, text: String, from: Double, to: Double) -> [String] {
        var said: [String] = []
        var time = from
        while time < to {
            if let words = schedule.next(degrees: degrees, text: text, at: time) {
                said.append(words)
            }
            time += 1.0 / 30
        }
        return said
    }

    @Test func offNeverSpeaks() {
        var schedule = SpeechSchedule(mode: .off)

        #expect(feed(&schedule, degrees: 10, text: "10 gradi", from: 0, to: 10).isEmpty)
    }

    @Test func aSettledReadingIsSaidOnceAfterASecond() {
        var schedule = SpeechSchedule(mode: .whenSettled)

        #expect(feed(&schedule, degrees: 10, text: "10 gradi", from: 0, to: 0.9).isEmpty)
        #expect(feed(&schedule, degrees: 10, text: "10 gradi", from: 0.9, to: 5) == ["10 gradi"])
    }

    @Test func aMovingReadingIsNotSaid() {
        var schedule = SpeechSchedule(mode: .whenSettled)
        var said: [String?] = []
        for step in 0..<90 {
            let degrees = Double(step)
            said.append(schedule.next(degrees: degrees, text: "\(step)", at: Double(step) / 30))
        }

        #expect(said.compactMap(\.self).isEmpty)
    }

    @Test func aNewSettledFigureIsSaidAgain() {
        var schedule = SpeechSchedule(mode: .whenSettled)
        _ = feed(&schedule, degrees: 10, text: "10 gradi", from: 0, to: 2)

        #expect(feed(&schedule, degrees: 20, text: "20 gradi", from: 2, to: 4) == ["20 gradi"])
    }

    @Test func noiseInsideTheToleranceStillSettles() {
        var schedule = SpeechSchedule(mode: .whenSettled)
        var said: [String] = []
        for step in 0..<60 {
            let degrees = 10 + (step.isMultiple(of: 2) ? 0.1 : -0.1)
            if let words = schedule.next(degrees: degrees, text: "10 gradi", at: Double(step) / 30) {
                said.append(words)
            }
        }

        #expect(said == ["10 gradi"])
    }

    @Test func theIntervalSpeaksEveryThreeSeconds() {
        var schedule = SpeechSchedule(mode: .interval)

        #expect(feed(&schedule, degrees: 10, text: "10 gradi", from: 0, to: 9.9).count == 4)
    }
}
