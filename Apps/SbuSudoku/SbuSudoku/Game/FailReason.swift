/// Why a game ended without the solution.
nonisolated enum FailReason: String, Codable, Sendable {
    /// The third mistake, with the mistake limit on.
    case mistakes
}
