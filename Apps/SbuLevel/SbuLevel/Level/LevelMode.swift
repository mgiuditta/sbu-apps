/// How the iPhone is being used.
nonisolated enum LevelMode: Equatable, Sendable {
    /// Lying on its back: a bubble level for surfaces.
    case flat
    /// Standing on an edge: a clinometer for the angle of that edge.
    case edge
    /// Held up to the eye with the camera on: the angle of the line of sight to a distant point.
    case sight
}
