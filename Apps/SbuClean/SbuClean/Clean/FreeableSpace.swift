/// The space the home promises: what Sbu Clean found that you can free.
///
/// It counts each item once: the bin, the copies selected in duplicates and similar, every
/// screenshot and screen recording. Items kept forever never count. Videos and Live Photos
/// do not count: whether to keep a video is a choice, not clutter.
nonisolated enum FreeableSpace {
    static func ids(items: [MediaItem], state: CleanState, groups: [PhotoGroup], selection: GroupSelection) -> Set<String> {
        var ids = Set(state.trash)
        ids.formUnion(selection.selected(in: groups))
        for item in items where item.isScreenshot || item.isScreenRecording {
            ids.insert(item.id)
        }
        return ids.subtracting(state.keepForever)
    }

    /// The bytes of the given items, those not measured yet counting zero.
    static func bytes(of ids: some Sequence<String>, in itemsByID: [String: MediaItem]) -> Int64 {
        ids.reduce(0) { $0 + (itemsByID[$1]?.bytes ?? 0) }
    }
}
