import Foundation

/// One video of the batch, from the pick to the copy.
nonisolated struct VideoJob: Identifiable, Equatable, Sendable {
    let id: UUID
    /// The original in Photos, when it came from there.
    let assetID: String?
    /// The file name, such as "IMG_1669.MOV"; empty until the file is ready.
    var name: String = ""
    /// The imported file in the work folder.
    var file: URL?
    var source: SourceVideo?
    var state: JobState = .loading
    /// The compressed copy, kept for Condividi until the next batch.
    var output: URL?

    init(id: UUID = UUID(), assetID: String?, name: String = "", file: URL? = nil, source: SourceVideo? = nil, state: JobState = .loading, output: URL? = nil) {
        self.id = id
        self.assetID = assetID
        self.name = name
        self.file = file
        self.source = source
        self.state = state
        self.output = output
    }

    /// Whether it takes part in the run: read, and not left out.
    var isInRun: Bool {
        source != nil && state != .unreadable && state != .loading
    }
}
