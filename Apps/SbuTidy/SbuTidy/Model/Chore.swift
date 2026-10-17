import Foundation
import SwiftData

/// A cleaning task in a room: how often, how much work, and when it was last done.
///
/// The cycle lives in `ChoreClock`, a pure type; this class stores it and keeps the history.
@Model
final class Chore {
    var id = UUID()
    var name = ""
    var frequencyValue = 1
    var frequencyUnitRaw = FrequencyUnit.week.rawValue
    var effortRaw = Effort.medium.rawValue
    var notes = ""
    /// Done once and gone, like Tody's one-off tasks.
    var isOneOff = false
    /// When you said it was last done on creation: the cycle restarts here if the history empties.
    var startedAt = Date.now
    var lastDone = Date.now
    var pausedAt: Date?
    var pausedSeconds: Double = 0
    var createdAt = Date.now

    var room: Room?
    @Relationship(deleteRule: .cascade, inverse: \Completion.chore) var completions: [Completion]? = []

    init(name: String, frequency: Frequency, effort: Effort, lastDone: Date) {
        self.name = name
        frequencyValue = frequency.value
        frequencyUnitRaw = frequency.unit.rawValue
        effortRaw = effort.rawValue
        startedAt = lastDone
        self.lastDone = lastDone
    }

    var frequency: Frequency {
        get { Frequency(frequencyValue, FrequencyUnit(rawValue: frequencyUnitRaw) ?? .week) }
        set {
            frequencyValue = newValue.value
            frequencyUnitRaw = newValue.unit.rawValue
        }
    }

    var effort: Effort {
        get { Effort(clamping: effortRaw) }
        set { effortRaw = newValue.rawValue }
    }

    var clock: ChoreClock {
        get { ChoreClock(lastDone: lastDone, pausedAt: pausedAt, pausedSeconds: pausedSeconds) }
        set {
            lastDone = newValue.lastDone
            pausedAt = newValue.pausedAt
            pausedSeconds = newValue.pausedSeconds
        }
    }

    /// The history, latest first.
    var history: [Completion] {
        (completions ?? []).sorted { $0.date > $1.date }
    }

    var snapshot: ChoreSnapshot {
        ChoreSnapshot(
            id: id, name: name, roomID: room?.id ?? id, roomName: room?.name ?? "", roomOrder: room?.order ?? 0,
            effort: effort, frequency: frequency, clock: clock
        )
    }

    func state(at now: Date, calendar: Calendar) -> ChoreState {
        ChoreState(frequency: frequency, clock: clock, now: now, calendar: calendar)
    }

    /// "Fatta ora" or "Fatta il…": adds to the history and, if it is the latest, starts a new
    /// cycle. A one-off chore is deleted instead, as in Tody. A date in the future counts as now.
    func markDone(at date: Date, now: Date = .now, in context: ModelContext) {
        if isOneOff {
            context.delete(self)
            return
        }
        let date = min(date, now)
        let completion = Completion(date: date)
        context.insert(completion)
        completion.chore = self
        var clock = clock
        clock.markDone(at: date, now: now)
        self.clock = clock
    }

    func pause(at now: Date = .now) {
        var clock = clock
        clock.pause(at: now)
        self.clock = clock
    }

    func resume(at now: Date = .now) {
        var clock = clock
        clock.resume(at: now)
        self.clock = clock
    }

    /// The latest completion on the day of `now`: the tick of the to-do list, taken back with `remove`.
    func completion(on now: Date, calendar: Calendar) -> Completion? {
        history.first { calendar.isDate($0.date, inSameDayAs: now) }
    }

    /// Removes one entry of the history; the cycle starts again from the latest one left.
    func remove(_ completion: Completion, in context: ModelContext) {
        let remaining = (completions ?? []).filter { $0.id != completion.id }.map(\.date)
        completions = (completions ?? []).filter { $0.id != completion.id }
        context.delete(completion)
        var clock = clock
        clock.restart(from: remaining, start: startedAt)
        self.clock = clock
    }
}
