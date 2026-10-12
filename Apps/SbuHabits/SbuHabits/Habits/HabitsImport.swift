import Foundation

/// A file chosen with Importa, checked and ready to replace the current data.
nonisolated struct HabitsImport: Identifiable, Sendable {
    let id = UUID()
    let file: HabitsFile

    /// The day the oldest habit started, or `nil` for a file without habits.
    var firstDay: LogicalDay? {
        file.habits.map(\.createdOn).min()
    }

    /// Checks `data`: not empty, a Sbu Habits file, from this version of the app or an older one.
    init(data: Data) throws(Failure) {
        guard data.isEmpty == false else { throw .empty }
        let decoder = JSONDecoder()
        // The version first: a newer file may not decode, and should say why.
        guard let version = try? decoder.decode(Header.self, from: data).version else { throw .damaged }
        guard version <= HabitsFile.currentVersion else { throw .newerVersion }
        guard var file = try? decoder.decode(HabitsFile.self, from: data) else { throw .damaged }
        file.startHour = Habit.clamp(file.startHour, to: HabitsFile.startHourRange)
        self.file = file
    }

    /// Reads the file the document picker returned, which lives outside the app's sandbox.
    init(contentsOf url: URL) throws(Failure) {
        let isScoped = url.startAccessingSecurityScopedResource()
        defer {
            if isScoped {
                url.stopAccessingSecurityScopedResource()
            }
        }
        guard let data = try? Data(contentsOf: url) else { throw .unreadable }
        try self.init(data: data)
    }

    private struct Header: Decodable {
        let version: Int
    }
}
