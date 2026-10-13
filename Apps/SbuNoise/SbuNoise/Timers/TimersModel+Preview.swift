import Foundation

extension TimersModel {
    /// Two timers on a throwaway file, for previews.
    static var preview: TimersModel {
        let store = NoiseStore(url: .temporaryDirectory.appending(path: "preview-\(UUID().uuidString).json"))
        let model = TimersModel(store: store, player: PlayerModel())
        model.save(SoundTimer(fade: .oneMinute, trigger: .duration(minutes: 45)))
        model.save(SoundTimer(trigger: .clock(hour: 23, minute: 30), weekdays: [1, 2, 3, 4, 5, 6, 7]))
        return model
    }
}
