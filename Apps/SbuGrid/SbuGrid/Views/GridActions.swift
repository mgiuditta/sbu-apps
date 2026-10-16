/// What the pills under the photo open.
struct GridActions {
    let showGrid: () -> Void
    let showPaper: () -> Void
    let showFullScreen: () -> Void
    let showTrace: () -> Void

    /// Does nothing, for previews.
    static let preview = GridActions(showGrid: {}, showPaper: {}, showFullScreen: {}, showTrace: {})
}
