/// What a run achieved, for the Fatto screen: before, after and the space saved.
nonisolated struct BatchSummary: Equatable, Sendable {
    /// The originals of the videos the run went through (compressed or kept as they were).
    let beforeBytes: Int64
    /// What those videos weigh now: the copies, and the originals that stayed.
    let afterBytes: Int64
    /// Videos with a lighter copy.
    let compressed: Int
    /// Of those, the copies saved in Photos.
    let savedToPhotos: Int
    /// Videos already as light as they could get.
    let notSmaller: Int
    /// Videos the encoder or the import could not handle.
    let failed: Int
    /// Videos left out by Annulla.
    let cancelled: Int
    /// The originals in Photos whose copy is safe in Photos: what "Elimina originali" deletes.
    let deletableIDs: [String]

    var savedBytes: Int64 { max(beforeBytes - afterBytes, 0) }

    /// The share saved, 0 to 1.
    var savedFraction: Double {
        beforeBytes > 0 ? Double(savedBytes) / Double(beforeBytes) : 0
    }

    init(jobs: [VideoJob]) {
        var before: Int64 = 0
        var after: Int64 = 0
        var compressed = 0
        var saved = 0
        var notSmaller = 0
        var failed = 0
        var cancelled = 0
        var deletable: [String] = []
        for job in jobs {
            let original = max(job.source?.bytes ?? 0, 0)
            switch job.state {
            case .done(let bytes, let isSaved):
                before += original
                after += max(min(bytes, original), 0)
                compressed += 1
                if isSaved {
                    saved += 1
                    if let id = job.assetID { deletable.append(id) }
                }
            case .notSmaller:
                before += original
                after += original
                notSmaller += 1
            case .failed, .unreadable:
                failed += 1
            case .cancelled:
                cancelled += 1
            case .loading, .waiting, .compressing:
                break
            }
        }
        beforeBytes = before
        afterBytes = after
        self.compressed = compressed
        savedToPhotos = saved
        self.notSmaller = notSmaller
        self.failed = failed
        self.cancelled = cancelled
        deletableIDs = deletable
    }
}
