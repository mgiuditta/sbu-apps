import Foundation
import Testing
@testable import SbuNoise

struct TimersModelTests {
    private let store = NoiseStore(url: .temporaryDirectory.appending(path: "TimersModelTests-\(UUID().uuidString)/noise.json"))
    private let player = PlayerModel(defaults: UserDefaults(suiteName: UUID().uuidString)!)
    private let start = Date(timeIntervalSince1970: 1_000_000)

    private func model() -> TimersModel {
        TimersModel(store: store, player: player) { [start] in start }
    }

    @Test func aSavedDurationStartsCountingAndIsKept() throws {
        let timers = model()
        timers.save(SoundTimer(trigger: .duration(minutes: 30)))
        #expect(timers.next?.date == start.addingTimeInterval(1_800))
        #expect(model().timers == timers.timers)
    }

    @Test func editingReplacesTheTimer() {
        let timers = model()
        var timer = SoundTimer(trigger: .duration(minutes: 30))
        timers.save(timer)
        timer.fade = .fiveMinutes
        timers.save(timer)
        #expect(timers.timers.map(\.fade) == [.fiveMinutes])
    }

    @Test func aOneOffTimerTurnsOffWhenItFires() {
        let timers = model()
        let timer = SoundTimer(trigger: .duration(minutes: 30))
        timers.save(timer)
        timers.fired(timer.id)
        #expect(timers.timers.first?.isOn == false)
        #expect(timers.next == nil)
    }

    @Test func aRepeatingDurationCountsAgainWhenASoundStarts() {
        let timers = model()
        let timer = SoundTimer(trigger: .duration(minutes: 30), repeatsAlways: true)
        timers.save(timer)
        timers.fired(timer.id)
        #expect(timers.next == nil)
        timers.playbackStarted()
        #expect(timers.next?.date == start.addingTimeInterval(1_800))
    }

    @Test func switchingOffAndDeletingClearTheNextTimer() {
        let timers = model()
        let timer = SoundTimer(trigger: .duration(minutes: 30))
        timers.save(timer)
        timers.setOn(false, for: timer.id)
        #expect(timers.next == nil)
        timers.delete(timer.id)
        #expect(timers.timers.isEmpty)
    }

    @Test func aTimerFadesOutAndStopsTheSound() async throws {
        let timers = TimersModel(store: store, player: player)
        player.togglePlayback()
        timers.save(SoundTimer(fade: .none, trigger: .duration(minutes: 0)))
        try await Task.sleep(for: .milliseconds(300))
        #expect(!player.isPlaying)
        #expect(timers.timers.first?.isOn == false)
    }
}
