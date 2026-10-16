import Foundation
import Observation

/// The batch, from the pick to the originals: one video or many, always the same flow.
///
/// Videos are read one at a time as they arrive, compressed one at a time in the order they were
/// picked, and each copy goes to Photos as soon as it is ready, so Annulla keeps what is done.
/// A video that fails does not stop the queue.
@Observable
final class ShrinkModel {
    typealias Probe = @Sendable (URL) async throws -> SourceVideo

    private(set) var stage: Stage = .picking
    private(set) var jobs: [VideoJob] = []
    private(set) var deletion: Deletion = .idle
    /// The permission to write to Photos, as of the last run.
    private(set) var access: LibraryAccess

    var settings: CompressionSettings {
        didSet { preferences.settings = settings }
    }

    var savesToAlbum: Bool {
        didSet { preferences.savesToAlbum = savesToAlbum }
    }

    private let compressor: any VideoCompressor
    private let library: any VideoLibrary
    private let preferences: Preferences
    private let probe: Probe
    @ObservationIgnored private var loading: Task<Void, Never>?
    @ObservationIgnored private var running: Task<Void, Never>?

    init(
        compressor: any VideoCompressor = AssetCompressor(),
        library: any VideoLibrary = PhotoKitLibrary(),
        preferences: Preferences = Preferences(),
        probe: @escaping Probe = { try await VideoProbe.source(at: $0) }
    ) {
        self.compressor = compressor
        self.library = library
        self.preferences = preferences
        self.probe = probe
        settings = preferences.settings
        savesToAlbum = preferences.savesToAlbum
        access = library.access()
    }

    // MARK: - What the screens show

    /// The videos read and ready, in the order they were picked.
    var readyJobs: [VideoJob] { jobs.filter(\.isInRun) }

    /// Whether some picked videos are still being copied or read.
    var isLoading: Bool { jobs.contains { $0.state == .loading } }

    /// The plan of a video with the current settings.
    func plan(for job: VideoJob) -> CompressionPlan? {
        job.source.map { CompressionPlan(source: $0, settings: settings) }
    }

    /// What the ready videos weigh now.
    var totalBytes: Int64 {
        readyJobs.reduce(0) { $0 + max($1.source?.bytes ?? 0, 0) }
    }

    /// What they should weigh after compressing.
    var estimatedBytes: Int64 {
        readyJobs.reduce(0) { $0 + (plan(for: $1)?.estimatedBytes ?? 0) }
    }

    /// The share the estimate saves, 0 to 1.
    var estimatedSavedFraction: Double {
        let total = totalBytes
        guard total > 0 else { return 0 }
        return max(0, 1 - Double(estimatedBytes) / Double(total))
    }

    /// How the target in MB fits the ready videos: the worst case, when there is a target.
    var targetFit: TargetFit? {
        let fits = readyJobs.compactMap { plan(for: $0)?.targetFit }
        if fits.contains(.tooSmall) { return .tooSmall }
        if fits.contains(.fits) { return .fits }
        return fits.first
    }

    /// Picked videos that are not videos the iPhone can read.
    var unreadableCount: Int { jobs.count { $0.state == .unreadable } }

    var canCompress: Bool { !isLoading && !readyJobs.isEmpty && stage == .settings }

    var progress: BatchProgress { BatchProgress(jobs: jobs) }

    var summary: BatchSummary { BatchSummary(jobs: jobs) }

    // MARK: - Steps

    /// Starts a batch with the videos just picked; an empty pick changes nothing.
    func pick(_ videos: [PendingVideo]) {
        guard !videos.isEmpty, stage == .picking || stage == .settings else { return }
        clear()
        jobs = videos.map { VideoJob(id: $0.id, assetID: $0.assetID) }
        stage = .settings
        loading = Task { await load(videos) }
    }

    /// Reads the picked videos one at a time, so the first ones show while the rest arrive.
    func load(_ videos: [PendingVideo]) async {
        for video in videos {
            if Task.isCancelled { return }
            do {
                let file = try await video.load()
                let source = try await probe(file)
                update(video.id) { job in
                    job.file = file
                    job.name = file.lastPathComponent
                    job.source = source
                    job.state = .waiting
                }
            } catch {
                update(video.id) { $0.state = .unreadable }
            }
        }
    }

    /// Back to the pick from the settings: the batch is dropped.
    func discard() {
        guard stage == .settings else { return }
        clear()
        stage = .picking
    }

    /// Starts the run in the background of the screen.
    func compress() {
        guard canCompress else { return }
        stage = .compressing
        running = Task { await run() }
    }

    /// Compresses every waiting video in order. Asks for Photos the first time.
    func run() async {
        if library.access() == .notDetermined {
            access = await library.requestAccess()
        } else {
            access = library.access()
        }
        let settings = settings
        let savesToAlbum = savesToAlbum
        let order = jobs.filter { $0.state == .waiting }.map(\.id)

        for id in order {
            guard !Task.isCancelled else { break }
            guard let job = jobs.first(where: { $0.id == id }), let file = job.file, let source = job.source else { continue }
            await compress(job, file: file, source: source, plan: CompressionPlan(source: source, settings: settings), savesToAlbum: savesToAlbum)
        }

        for index in jobs.indices where jobs[index].state == .waiting {
            jobs[index].state = .cancelled
        }
        let summary = summary
        if summary.compressed + summary.notSmaller + summary.failed - unreadableCount > 0 {
            stage = .done
        } else {
            // Annulla before anything finished: back to the settings, as before the run.
            for index in jobs.indices where jobs[index].state == .cancelled {
                jobs[index].state = .waiting
            }
            stage = .settings
        }
    }

    /// Stops the run after the current check; finished videos stay in Photos.
    func cancel() {
        running?.cancel()
    }

    /// Deletes the originals whose copy is in Photos. iOS asks once more.
    func deleteOriginals() async {
        let ids = summary.deletableIDs
        guard !ids.isEmpty, deletion != .deleting else { return }
        deletion = .deleting
        do {
            deletion = .deleted(try await library.delete(ids))
        } catch LibraryError.cancelled {
            deletion = .idle
        } catch {
            deletion = .failed
        }
    }

    /// Ends the batch, keeping the originals, and goes back to the pick.
    func finish() {
        guard stage == .done else { return }
        clear()
        stage = .picking
    }

    /// The suggested settings, the main sliders and "Avanzate" alike.
    func restoreSuggestedSettings() {
        settings = CompressionSettings()
    }

    // MARK: - Private

    private func compress(_ job: VideoJob, file: URL, source: SourceVideo, plan: CompressionPlan, savesToAlbum: Bool) async {
        let id = job.id
        update(id) { $0.state = .compressing(0) }
        do {
            let output = try WorkFolder.output(for: file, format: plan.format)
            let bytes = try await compressor.compress(file, plan: plan, to: output) { [weak self] fraction in
                Task { @MainActor in self?.report(fraction, for: id) }
            }
            guard bytes > 0, bytes < source.bytes else {
                try? FileManager.default.removeItem(at: output)
                update(id) { $0.state = .notSmaller }
                return
            }
            var isSaved = false
            if access.canSave {
                isSaved = (try? await library.save(output, original: job.assetID, toAlbum: savesToAlbum)) != nil
            }
            update(id) { job in
                job.output = output
                job.state = .done(bytes: bytes, saved: isSaved)
            }
        } catch CompressionError.cancelled {
            update(id) { $0.state = .cancelled }
        } catch is CancellationError {
            update(id) { $0.state = .cancelled }
        } catch {
            update(id) { $0.state = .failed }
        }
    }

    /// A late report never moves a finished video back.
    private func report(_ fraction: Double, for id: UUID) {
        update(id) { job in
            if case .compressing(let current) = job.state, fraction > current {
                job.state = .compressing(min(fraction, 1))
            }
        }
    }

    private func update(_ id: UUID, _ change: (inout VideoJob) -> Void) {
        guard let index = jobs.firstIndex(where: { $0.id == id }) else { return }
        change(&jobs[index])
    }

    private func clear() {
        loading?.cancel()
        running?.cancel()
        loading = nil
        running = nil
        jobs = []
        deletion = .idle
        WorkFolder.clear()
    }
}
