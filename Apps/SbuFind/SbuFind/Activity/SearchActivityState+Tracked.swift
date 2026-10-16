// In the app only: the widget extension does not know the finder's types.
extension SearchActivityAttributes.ContentState {
    /// The state of the finder's device.
    init(tracked: TrackedDevice) {
        self.init(percent: tracked.device.proximity.value, warmth: tracked.warmth, isLost: tracked.isLost)
    }
}
