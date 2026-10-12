import Foundation

// Compiled in Release too: #Preview bodies are, and they use it.
extension HabitsModel {
    /// Three habits in a throwaway file, for previews: water 1 of 8, reading done, walking to do.
    static var preview: HabitsModel {
        let url = URL.temporaryDirectory.appending(path: "habits-preview-\(UUID().uuidString).json")
        let model = HabitsModel(store: HabitsStore(url: url))
        model.add(title: "Bere acqua", symbol: "drop", timesPerDay: 8)
        model.add(title: "Leggere", symbol: "book")
        model.add(title: "Camminare", symbol: "figure.walk")
        model.markDone(model.habits[0])
        model.markDone(model.habits[1])
        return model
    }
}
