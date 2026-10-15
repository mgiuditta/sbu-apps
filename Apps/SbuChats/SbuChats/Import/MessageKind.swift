/// What a line of the export is.
nonisolated enum MessageKind: String, CaseIterable, Sendable {
    /// Something a person wrote.
    case text
    /// A photo, video, audio, sticker or document attached to the export.
    case media
    /// A media message exported without its file ("image omitted").
    case omittedMedia = "omitted_media"
    /// A message its author deleted: it was sent, its words are gone.
    case deleted
    /// Written by the app: encryption notice, group changes, calls. Never counted as a message.
    case system

    /// Whether it counts as a message someone sent.
    var isMessage: Bool { self != .system }

    /// Whether it is a photo, video, audio or other file.
    var isMedia: Bool { self == .media || self == .omittedMedia }
}
