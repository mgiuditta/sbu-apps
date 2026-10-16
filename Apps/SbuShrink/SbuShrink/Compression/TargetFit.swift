/// How a target in MB fits a video.
nonisolated enum TargetFit: Equatable, Sendable {
    /// The copy will weigh about the target.
    case fits
    /// Even at the lowest quality the copy weighs more than the target: shorten the video or
    /// lower the dimensions.
    case tooSmall
    /// The video already fits at full quality: the copy will be lighter than the target.
    case alreadySmaller
}
