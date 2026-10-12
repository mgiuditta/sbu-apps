#if DEBUG
import Foundation

extension HabitsModel {
    /// Three habits in a throwaway file, two done today, for previews.
    static var preview: HabitsModel {
        let url = URL.temporaryDirectory.appending(path: "habits-preview-\(UUID().uuidString).json")
        let model = HabitsModel(store: HabitsStore(url: url))
        model.add(title: "Bere acqua", symbol: "drop")
        model.add(title: "Leggere", symbol: "book")
        model.add(title: "Camminare", symbol: "figure.walk")
        model.markDone(model.habits[0])
        model.markDone(model.habits[1])
        return model
    }
}
#endif
