import Foundation
@testable import SbuHabits

/// The copy on iCloud, in memory: what `HabitsSync` reads and writes in tests.
actor FakeRemote: HabitsRemote {
    private(set) var data: Data?
    private(set) var conflicts: [RemoteConflict] = []
    private(set) var writes = 0
    private(set) var resolved: [URL] = []

    init(_ file: HabitsFile? = nil) {
        data = file.flatMap { try? JSONEncoder().encode($0) }
    }

    /// Replaces the copy as another iPhone would.
    func put(_ data: Data) {
        self.data = data
    }

    func put(_ file: HabitsFile) throws {
        data = try JSONEncoder().encode(file)
    }

    /// Adds a version iCloud kept when two iPhones wrote at once.
    func addConflict(_ file: HabitsFile) throws {
        conflicts.append(RemoteConflict(url: URL(filePath: "/conflict-\(conflicts.count)"), data: try JSONEncoder().encode(file)))
    }

    var file: HabitsFile? {
        data.flatMap { try? JSONDecoder().decode(HabitsFile.self, from: $0) }
    }

    func read() async throws -> RemoteRead {
        guard let data else { return .missing }
        return .found(data, conflicts: conflicts)
    }

    func write(_ data: Data, resolving conflicts: [RemoteConflict]) async throws {
        self.data = data
        writes += 1
        resolved += conflicts.map(\.url)
        self.conflicts.removeAll { conflict in conflicts.contains(conflict) }
    }
}
