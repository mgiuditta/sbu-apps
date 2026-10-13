import Foundation
import Observation
import UIKit

/// The app's one model: the library as the cleaner sees it, the user's decisions, the bin,
/// the duplicate and similar groups, and the space all this frees.
///
/// PhotoKit stays behind `PhotoLibrary`, so the model runs in tests on a fake library. Built for
/// libraries of tens of thousands of items: indexing, summaries, grouping and every file write
/// run off the main actor, and the scan reports its progress a few times a second, not per photo.
@Observable
final class CleanModel {
    let library: any PhotoLibrary

    /// Whether the app may read the library.
    private(set) var access: LibraryAccess
    /// Whether the library has been read at least once since launch.
    private(set) var hasLoaded = false
    /// The user's decisions, saved off the main actor at every change.
    var state: CleanState {
        didSet { stateDidChange() }
    }
    /// Duplicate and similar groups from the last scan, best shot first.
    private(set) var groups: [PhotoGroup] = [] {
        didSet { refreshSummary() }
    }
    /// Which group members go to the bin.
    var groupSelection = GroupSelection() {
        didSet { refreshSummary() }
    }
    private(set) var scan = ScanState.idle
    private(set) var storage: DeviceStorage?
    /// The user's albums, read when the album list opens.
    private(set) var albums: [Album] = []
    /// What the home and the timeline show, worked out off the main actor after each change.
    private(set) var summary = LibrarySummary()
    private var index = LibraryIndex() {
        didSet { refreshSummary() }
    }

    @ObservationIgnored private let stateFile: StoredFile<CleanState>
    @ObservationIgnored private let sizesFile: StoredFile<[String: ItemSize]>
    @ObservationIgnored private let analysisStore: AnalysisStore
    @ObservationIgnored private var sizes: [String: ItemSize] = [:]
    @ObservationIgnored private var analyses: [String: ImageAnalysis] = [:]
    @ObservationIgnored private var cachesLoaded = false
    @ObservationIgnored private var scanTask: Task<Void, Never>?
    @ObservationIgnored private var summaryTask: Task<Void, Never>?
    @ObservationIgnored private var pendingSave: Task<Void, Never>?
    @ObservationIgnored let grouper: SimilarityGrouper
    @ObservationIgnored private let now: @Sendable () -> Date
    @ObservationIgnored private let readStorage: @Sendable () -> DeviceStorage?
    @ObservationIgnored private let publish: @Sendable (WidgetSnapshot) -> Void
    @ObservationIgnored private var lastPublished: Int64?

    /// How many photos are analysed at once: two keep the Neural Engine busy without starving
    /// the screen.
    private static let scanWidth = 2
    /// How many items are measured per call.
    private static let measureBatch = 2_000
    /// How many new analyses make one chunk on disk.
    private static let saveEvery = 500
    /// How often the scan's progress reaches the screen.
    private static let progressInterval: Duration = .milliseconds(250)

    /// Creates the model.
    /// - Parameters:
    ///   - library: PhotoKit, or a fake in tests and previews.
    ///   - directory: Where state and caches live; Application Support when `nil`.
    ///   - grouper: The duplicate and similar thresholds.
    ///   - now: The clock, for Recenti and Accadde oggi.
    ///   - readStorage: Reads the iPhone's capacity.
    ///   - publish: Hands the space you can free to the widget; nothing by default.
    init(
        library: any PhotoLibrary,
        directory: URL? = nil,
        grouper: SimilarityGrouper = SimilarityGrouper(),
        now: @escaping @Sendable () -> Date = { .now },
        readStorage: @escaping @Sendable () -> DeviceStorage? = { DeviceStorage.current() },
        publish: @escaping @Sendable (WidgetSnapshot) -> Void = { _ in }
    ) {
        self.library = library
        self.grouper = grouper
        self.now = now
        self.readStorage = readStorage
        self.publish = publish
        stateFile = StoredFile(name: "state.json", directory: directory)
        sizesFile = StoredFile(name: "sizes.plist", format: .binary, directory: directory)
        analysisStore = AnalysisStore(directory: directory)
        state = stateFile.load() ?? CleanState()
        access = library.currentAccess()
    }

    // MARK: - Library

    /// Every photo and video, newest first.
    var items: [MediaItem] {
        index.items
    }

    var itemsByID: [String: MediaItem] {
        index.byID
    }

    /// How many items still wait for their size.
    var unmeasuredCount: Int {
        index.unmeasuredCount
    }

    // MARK: - Loading

    /// Reads the library if allowed, then follows its changes until the task is cancelled.
    func start() async {
        access = library.currentAccess()
        guard access.canRead else { return }

        await reload()
        for await _ in library.changes() {
            await reload()
        }
    }

    /// Asks for access to the library and reads it when granted.
    func requestAccess() async {
        access = await library.requestAccess()
    }

    /// Reads the library again: new items get measured, missing ones leave the decisions.
    func reload() async {
        access = library.currentAccess()
        guard access.canRead else { return }

        if !cachesLoaded {
            cachesLoaded = true
            async let loadedSizes = Self.read(sizesFile)
            async let loadedAnalyses = analysisStore.load()
            sizes = await loadedSizes ?? [:]
            analyses = await loadedAnalyses
        }

        storage = readStorage()
        let fetched = await library.fetchItems()
        index = await Self.makeIndex(fetched, sizes: sizes)
        if access == .full {
            let pruned = await Self.pruned(state, keeping: index.byID)
            if pruned != state {
                state = pruned
            }
        }
        if groups.isEmpty && !analyses.isEmpty {
            await regroup()
        } else {
            pruneGroups()
        }
        hasLoaded = true
        await measureSizes()
        publishFreeableSpace()
        if !scan.isRunning {
            startScan()
        }
    }

    /// Tells the widget the space you can free, when it changed.
    func publishFreeableSpace() {
        let bytes = freeableBytes
        guard bytes != lastPublished else { return }

        lastPublished = bytes
        publish(WidgetSnapshot(freeableBytes: bytes, date: now()))
    }

    /// Reads the user's albums.
    func loadAlbums() async {
        albums = await library.albums()
    }

    private func measureSizes() async {
        let pending = index.items.filter { $0.size == nil }.map(\.id)
        guard !pending.isEmpty else { return }

        for start in stride(from: 0, to: pending.count, by: Self.measureBatch) {
            let batch = Array(pending[start..<min(start + Self.measureBatch, pending.count)])
            let measured = await library.measure(batch)
            sizes.merge(measured) { _, new in new }
            index = await Self.apply(measured, to: index)
        }
        await Self.writeSizes(sizes, keeping: index.byID, to: sizesFile)
    }

    // MARK: - Off the main actor

    @concurrent
    private nonisolated static func makeIndex(_ items: [MediaItem], sizes: [String: ItemSize]) async -> LibraryIndex {
        LibraryIndex(items: items, sizes: sizes)
    }

    @concurrent
    private nonisolated static func apply(_ measured: [String: ItemSize], to index: LibraryIndex) async -> LibraryIndex {
        index.applying(measured)
    }

    @concurrent
    private nonisolated static func pruned(_ state: CleanState, keeping existing: [String: MediaItem]) async -> CleanState {
        var pruned = state
        pruned.keepOnly(Set(existing.keys))
        return pruned
    }

    @concurrent
    private nonisolated static func read<Value: Codable & Sendable>(_ file: StoredFile<Value>) async -> Value? {
        file.load()
    }

    @concurrent
    private nonisolated static func writeSizes(_ sizes: [String: ItemSize], keeping existing: [String: MediaItem], to file: StoredFile<[String: ItemSize]>) async {
        try? file.save(sizes.filter { existing[$0.key] != nil })
    }

    @concurrent
    private nonisolated static func makeSummary(index: LibraryIndex, state: CleanState, groups: [PhotoGroup], selection: GroupSelection, now: Date) async -> LibrarySummary {
        LibrarySummary(items: index.items, monthOf: index.monthOf, state: state, groups: groups, selection: selection, now: now)
    }

    /// Works the summary out again off the main actor; a newer change cancels an older one.
    private func refreshSummary() {
        summaryTask?.cancel()
        let index = index
        let state = state
        let groups = groups
        let selection = groupSelection
        let now = now()
        summaryTask = Task {
            let summary = await Self.makeSummary(index: index, state: state, groups: groups, selection: selection, now: now)
            guard !Task.isCancelled else { return }

            self.summary = summary
        }
    }

    /// Waits for the summary to catch up with the last change.
    func waitForSummary() async {
        await summaryTask?.value
    }

    private func stateDidChange() {
        let state = state
        let file = stateFile
        let previous = pendingSave
        // In order, off the main actor: each save waits for the one before.
        pendingSave = Task.detached(priority: .utility) {
            await previous?.value
            try? file.save(state)
        }
        refreshSummary()
    }

    /// Waits until the decisions are on disk.
    func waitForSaves() async {
        await pendingSave?.value
    }

    // MARK: - Space

    /// What the home promises: the bin, the selected copies, screenshots and recordings.
    /// Worked out now; the screens read `summary`, which is worked out off the main actor.
    var freeableBytes: Int64 {
        bytes(of: FreeableSpace.ids(items: items, state: state, groups: groups, selection: groupSelection))
    }

    /// What waits in the bin.
    var trashBytes: Int64 {
        bytes(of: state.trash)
    }

    func bytes(of ids: some Sequence<String>) -> Int64 {
        FreeableSpace.bytes(of: ids, in: itemsByID)
    }

    /// The items of a category, biggest first, those kept forever left out.
    func items(in category: MediaCategory) -> [MediaItem] {
        items
            .filter { $0.belongs(to: category) && !state.keepForever.contains($0.id) }
            .sorted { $0.bytes > $1.bytes }
    }

    /// The queues and the timeline over the current library and decisions.
    var queues: QueueBuilder {
        QueueBuilder(items: items, state: state, now: now())
    }

    // MARK: - Decisions

    /// Records a decision about an item and returns the one it replaced, for undo.
    @discardableResult
    func decide(_ decision: SwipeDecision?, on id: String) -> SwipeDecision? {
        let previous = state.decision(for: id)
        state.set(decision, for: id)
        return previous
    }

    /// Puts items in the bin.
    func moveToTrash(_ ids: some Sequence<String>) {
        state.addToTrash(ids)
    }

    /// Makes every kept and set-aside item to see again; the bin and the items kept forever stay.
    func resetProgress() {
        state.kept = []
        state.later = []
    }

    /// Takes an item out of the bin: it goes back to the queues.
    func restore(_ id: String) {
        state.set(nil, for: id)
    }

    /// Deletes everything in the bin. The system asks the user first; when the user says no,
    /// this throws and the bin stays as it was.
    func deleteTrash() async throws -> DeletionResult {
        let ids = state.trash
        let bytes = bytes(of: ids)
        try await library.delete(ids)

        let deleted = Set(ids)
        state.freed.record(count: ids.count, bytes: bytes, on: now())
        state.forget(deleted)
        index = index.removing(deleted)
        for id in deleted {
            analyses[id] = nil
        }
        pruneGroups()
        storage = readStorage()
        publishFreeableSpace()
        return DeletionResult(count: ids.count, bytes: bytes, totalBytes: state.freed.totalBytes, totalCount: state.freed.totalCount)
    }

    // MARK: - Live Photos and videos

    /// Saves a still copy of each Live Photo and puts the originals in the bin, for the final
    /// review. Returns how many were converted; those that fail stay as they were.
    func convertLivePhotos(_ ids: [String]) async -> Int {
        var converted: [String] = []
        for id in ids {
            if (try? await library.saveStill(ofLivePhoto: id)) != nil {
                converted.append(id)
            }
        }
        moveToTrash(converted)
        await reload()
        return converted.count
    }

    /// Saves a compressed copy of a video; the original stays until the user decides.
    func compress(_ id: String, quality: CompressionQuality, progress: @escaping @Sendable (CompressionStep) -> Void = { _ in }) async throws {
        _ = try await library.saveCompressed(video: id, quality: quality, progress: progress)
        await reload()
    }

    // MARK: - Duplicates and similar

    /// The groups of one kind.
    func groups(of kind: GroupKind) -> [PhotoGroup] {
        groups.filter { $0.kind == kind }
    }

    /// The members selected for the bin, in the groups of one kind or all of them.
    func selectedGroupMembers(of kind: GroupKind? = nil) -> [String] {
        groupSelection.selected(in: kind.map(groups(of:)) ?? groups)
    }

    /// Analyses the photos not analysed yet, then groups the whole library again.
    func startScan() {
        guard !scan.isRunning, access.canRead else { return }

        // Below the screen's priority: the scan never competes with a scroll or a swipe.
        scanTask = Task(priority: .utility) {
            await runScan()
        }
    }

    /// Waits for the running scan, if any, to end.
    func waitForScan() async {
        await scanTask?.value
    }

    /// Stops the scan; what was analysed is kept, and the next scan goes on from there.
    func cancelScan() {
        scanTask?.cancel()
    }

    private func runScan() async {
        let analysed = analyses
        let pending = items.filter { $0.kind == .photo && analysed[$0.id] == nil }.map(\.id)
        let total = pending.count
        scan = .running(done: 0, total: total)
        let library = library
        let store = analysisStore
        // Going to the background, the scan gets the time iOS grants to finish work; when it
        // runs out, the scan stops and saves what it has, and the next one goes on from there.
        let backgroundTask = UIApplication.shared.beginBackgroundTask(withName: "Sbu Clean scan") { [weak self] in
            self?.cancelScan()
        }
        defer { UIApplication.shared.endBackgroundTask(backgroundTask) }

        var done = 0
        var unsaved: [String: ImageAnalysis] = [:]
        let clock = ContinuousClock()
        var lastReport = clock.now
        await withTaskGroup(of: (String, ImageAnalysis?).self) { group in
            var queue = pending.makeIterator()
            for _ in 0..<Self.scanWidth {
                guard let id = queue.next() else { break }
                group.addTask(priority: .utility) { (id, await library.analyze(id)) }
            }
            while let (id, analysis) = await group.next() {
                analyses[id] = analysis
                unsaved[id] = analysis
                done += 1
                if clock.now - lastReport >= Self.progressInterval || done == total {
                    lastReport = clock.now
                    scan = .running(done: done, total: total)
                }
                if unsaved.count >= Self.saveEvery {
                    await store.append(unsaved)
                    unsaved = [:]
                }
                guard !Task.isCancelled else {
                    group.cancelAll()
                    break
                }
                if let next = queue.next() {
                    group.addTask(priority: .utility) { (next, await library.analyze(next)) }
                }
            }
        }

        await store.append(unsaved)
        await store.compact(analyses, keep: Set(itemsByID.keys))
        await regroup()
        scan = Task.isCancelled ? .cancelled : .finished
        publishFreeableSpace()
    }

    private func regroup() async {
        let fresh = await Self.computeGroups(items: items, analyses: analyses, grouper: grouper)
        groups = Self.pruning(fresh, existing: itemsByID, keptForever: state.keepForever)
    }

    @concurrent
    private nonisolated static func computeGroups(items: [MediaItem], analyses: [String: ImageAnalysis], grouper: SimilarityGrouper) async -> [PhotoGroup] {
        grouper.groups(of: items, analyses: analyses)
    }

    /// Drops deleted members from the groups, and groups left with one member.
    private func pruneGroups() {
        let pruned = Self.pruning(groups, existing: itemsByID, keptForever: state.keepForever)
        if pruned != groups {
            groups = pruned
        }
    }

    private nonisolated static func pruning(_ groups: [PhotoGroup], existing: [String: MediaItem], keptForever: Set<String>) -> [PhotoGroup] {
        groups.compactMap { group in
            var pruned = group
            pruned.members = group.members.filter { existing[$0] != nil && !keptForever.contains($0) }
            return pruned.members.count > 1 ? pruned : nil
        }
    }
}
