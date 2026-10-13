import Foundation

extension AlarmsModel {
    /// One alarm on a throwaway file, with a backup that does nothing, for previews.
    static func preview(player: PlayerModel) -> AlarmsModel {
        let store = NoiseStore(url: .temporaryDirectory.appending(path: "preview-\(UUID().uuidString).json"))
        let model = AlarmsModel(store: store, player: player, backup: SilentBackup())
        model.save(SoundAlarm(hour: 7, minute: 15, weekdays: [2, 3, 4, 5, 6]))
        return model
    }
}
