import Foundation

/// Groups photos into duplicates and similar shots from their Vision feature prints.
///
/// Thresholds come from the fixture set in `Fixtures/make_fixtures.py`, measured with
/// revision 2 of the feature print: copies saved again sit under 0.08, bursts and slightly
/// cropped or brighter copies between 0.03 and 0.22, different pictures above 0.29.
///
/// It scales to libraries of tens of thousands of photos: a photo is compared only with the
/// photos taken within a day of it (sorted by date, so each comparison window is short), and
/// with the photos of exactly the same file size, which catches a copy saved again much later.
nonisolated struct SimilarityGrouper: Sendable {
    /// Two photos closer than this are the same picture.
    var duplicateDistance: Float = 0.10
    /// Two photos closer than this, taken within `similarWindow`, are similar shots.
    var similarDistance: Float = 0.25
    /// How far apart in time two similar shots can be.
    var similarWindow: TimeInterval = 15 * 60
    /// How far apart in time two photos are compared as duplicates.
    var duplicateWindow: TimeInterval = 24 * 3600
    /// Same-size buckets bigger than this are ordinary sizes, not copies, and are skipped.
    var maxSameSizeBucket = 50

    /// Duplicate groups first, then similar groups, each newest first, best shot first.
    ///
    /// Photos join when they are duplicates, or similar shots close in time; a group made only
    /// of duplicates is a duplicate group, any other is similar, so a burst with a blurred shot
    /// stays one group. A photo is in one group at most. Screenshots join only as duplicates:
    /// two screens of the same app look alike without being retakes.
    func groups(of items: [MediaItem], analyses: [String: ImageAnalysis]) -> [PhotoGroup] {
        let scanned = items
            .filter { $0.kind == .photo && !(analyses[$0.id]?.featurePrint.isEmpty ?? true) }
            .sorted { ($0.creationDate ?? .distantPast) < ($1.creationDate ?? .distantPast) }
        let prints = scanned.map { analyses[$0.id]?.featurePrint ?? [] }
        let dates = scanned.map { $0.creationDate ?? .distantPast }

        var duplicates = UnionFind(count: scanned.count)
        var all = UnionFind(count: scanned.count)

        // Within a day of each other, sorted by date: short windows, never all pairs.
        for first in scanned.indices {
            for second in (first + 1)..<scanned.count {
                let gap = dates[second].timeIntervalSince(dates[first])
                guard gap <= duplicateWindow else { break }

                let distance = FeatureDistance.between(prints[first], prints[second])
                if distance <= duplicateDistance {
                    duplicates.join(first, second)
                    all.join(first, second)
                } else if gap <= similarWindow, distance <= similarDistance,
                          !scanned[first].isScreenshot, !scanned[second].isScreenshot {
                    all.join(first, second)
                }
            }
        }

        // The same file saved again at another time has the same size.
        var bySize: [Int64: [Int]] = [:]
        for index in scanned.indices where scanned[index].bytes > 0 {
            bySize[scanned[index].bytes, default: []].append(index)
        }
        for bucket in bySize.values where bucket.count > 1 && bucket.count <= maxSameSizeBucket {
            for (position, first) in bucket.enumerated() {
                for second in bucket[(position + 1)...] where FeatureDistance.between(prints[first], prints[second]) <= duplicateDistance {
                    duplicates.join(first, second)
                    all.join(first, second)
                }
            }
        }

        var duplicateGroups: [[Int]] = []
        var similarGroups: [[Int]] = []
        for group in all.groups() {
            let root = duplicates.root(of: group[0])
            if group.allSatisfy({ duplicates.root(of: $0) == root }) {
                duplicateGroups.append(group)
            } else {
                similarGroups.append(group)
            }
        }

        let make = { (kind: GroupKind, indices: [Int]) -> PhotoGroup in
            let candidates = indices.map { index in
                let item = scanned[index]
                let analysis = analyses[item.id]
                return ShotCandidate(
                    id: item.id,
                    isFavorite: item.isFavorite,
                    hasAdjustments: item.hasAdjustments,
                    faceQuality: analysis?.faceQuality,
                    sharpness: analysis?.sharpness ?? 0,
                    pixelCount: item.pixelCount,
                    date: item.creationDate
                )
            }
            return PhotoGroup(kind: kind, members: BestShot.ordered(candidates))
        }
        // Union-find lists groups by their oldest member; the screen shows the newest first.
        return duplicateGroups.reversed().map { make(.duplicate, $0) }
            + similarGroups.reversed().map { make(.similar, $0) }
    }
}
