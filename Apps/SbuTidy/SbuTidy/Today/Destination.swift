/// Screens pushed from the to-do list besides a room or a chore.
enum Destination: Hashable {
    /// Tody's "Aree" tab; Sbu has no tab bar (ADR-0001), so it opens from the toolbar.
    case rooms
}
