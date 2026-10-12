import Foundation

// Compiled in Release too: #Preview bodies are, and they use it.
extension HabitsImport {
    /// The demo habits, exported and read back as Importa would.
    static var preview: HabitsImport {
        // The app's own export always passes the checks.
        try! HabitsImport(data: HabitsExport(file: .demo(today: LogicalDay(.now)), date: .now).data())
    }
}
