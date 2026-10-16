/// The progress of a run over its videos, as the original shows it: one overall percentage and
/// "video N di M".
nonisolated struct BatchProgress: Equatable, Sendable {
    /// 0 to 1, each video weighing by its length, so a long video moves the figure more.
    let fraction: Double
    /// The video being compressed, from 1; the last one when the run is over.
    let current: Int
    /// The videos in the run.
    let total: Int

    init(jobs: [VideoJob]) {
        let inRun = jobs.filter(\.isInRun)
        total = inRun.count
        let weights = inRun.map { job in
            let duration = job.source?.duration ?? 0
            return duration.isFinite && duration > 0 ? duration : 1
        }
        let weight = weights.reduce(0, +)
        let done = zip(inRun, weights).reduce(0) { sum, pair in sum + pair.0.state.fraction * pair.1 }
        fraction = weight > 0 ? (done / weight).clamped(to: 0...1) : 0

        if let running = inRun.firstIndex(where: { !$0.state.isFinished && $0.state != .waiting }) {
            current = running + 1
        } else {
            current = min(inRun.count(where: \.state.isFinished) + 1, total)
        }
    }
}
