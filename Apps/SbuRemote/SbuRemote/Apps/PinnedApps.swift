import Foundation

/// The apps the user keeps in the remote's shortcut row, at most three per TV (#351).
nonisolated struct PinnedApps: Codable, Equatable, Sendable {
    static let limit = 3

    private var byTV: [UUID: [TVShortcut]] = [:]

    func apps(for tv: UUID) -> [TVShortcut] {
        byTV[tv] ?? []
    }

    func isPinned(_ app: TVShortcut, for tv: UUID) -> Bool {
        apps(for: tv).contains { $0.id == app.id }
    }

    func canPin(for tv: UUID) -> Bool {
        apps(for: tv).count < Self.limit
    }

    /// Pins or unpins; pinning a fourth app does nothing.
    mutating func toggle(_ app: TVShortcut, for tv: UUID) {
        var list = apps(for: tv)
        if let index = list.firstIndex(where: { $0.id == app.id }) {
            list.remove(at: index)
        } else if list.count < Self.limit {
            list.append(app)
        }
        byTV[tv] = list.isEmpty ? nil : list
    }

    mutating func removeAll(for tv: UUID) {
        byTV[tv] = nil
    }
}
