import Foundation

/// A tap on the Apple Watch, queued for the iPhone: which habit, the logical day and the hour on
/// the clock it happened at, and whether it adds a mark or takes the last one back.
///
/// The iPhone applies it as a tap there, through `WatchMarking`, and lists its `id` in the next
/// `WatchSnapshot`, so the watch knows it arrived.
nonisolated struct WatchAction: Codable, Equatable, Identifiable, Sendable {
    enum Kind: String, Codable, Sendable {
        /// One time done, or for an Abitudine da evitare one more time given in.
        case mark
        /// Today's last mark taken back.
        case undo
    }

    let id: UUID
    let habitID: UUID
    let day: LogicalDay
    /// 0 to 23, on the watch's clock, for the hours of the Statistiche and the Orari automatici.
    let hour: Int
    let kind: Kind

    init(id: UUID = UUID(), habitID: UUID, day: LogicalDay, hour: Int, kind: Kind) {
        self.id = id
        self.habitID = habitID
        self.day = day
        self.hour = hour
        self.kind = kind
    }
}
