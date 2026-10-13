/// The tool screen's grid in pages, as Streaks lays it out: six places a page (two columns,
/// three rows), today's habits in the user's order, then the Abitudini condivise received, then
/// Aggiungi as the last place.
///
/// At most 24 habits, four full pages. Aggiungi takes a place only while a habit can still be
/// added: at 24 it goes, so the grid never grows a fifth page that holds a lone button. The
/// limit counts every habit, those not expected today included, since they come back on
/// their days. The Abitudini condivise received are someone else's: they never count toward the
/// limit, and show every day, being the only way to open them.
nonisolated struct HomePages: Equatable, Sendable {
    /// One place of the grid.
    enum Slot: Hashable, Sendable {
        case habit(Habit)
        /// An Abitudine condivisa someone else shares: read only.
        case shared(ReceivedHabit)
        /// The ring with a plus that opens the form.
        case add
    }

    /// Places on a page: two columns, three rows.
    static let pageSize = 6
    /// Pages a full grid fills.
    static let pageLimit = 4
    /// The most habits there can be: four full pages, as in Streaks.
    static let habitLimit = pageSize * pageLimit

    /// The pages, each with up to `pageSize` places; never empty, so the first page always exists.
    let pages: [[Slot]]
    /// A habit can still be added: Aggiungi is the last place.
    let canAdd: Bool

    /// - Parameters:
    ///   - todayHabits: The habits the grid shows today, already in order (`TodayGrid`).
    ///   - habitCount: Every habit saved, today's and the others.
    ///   - isAddEnabled: `false` when nothing can be added anyway, such as an unreadable file.
    ///   - shared: The Abitudini condivise received, after the user's own.
    init(todayHabits: [Habit], habitCount: Int, isAddEnabled: Bool = true, shared: [ReceivedHabit] = []) {
        canAdd = isAddEnabled && habitCount < Self.habitLimit
        let slots = todayHabits.map(Slot.habit) + shared.map(Slot.shared) + (canAdd ? [.add] : [])
        let pages = stride(from: 0, to: slots.count, by: Self.pageSize).map {
            Array(slots[$0..<min($0 + Self.pageSize, slots.count)])
        }
        self.pages = pages.isEmpty ? [[]] : pages
    }

    /// Every place in order, for the single column at accessibility text sizes.
    var allSlots: [Slot] {
        pages.flatMap(\.self)
    }

    /// The page that exists closest to `page`, for when habits go and a page with them.
    func clamped(_ page: Int) -> Int {
        min(max(page, 0), pages.count - 1)
    }
}

extension HomePages.Slot: Identifiable {
    var id: String {
        switch self {
        case .habit(let habit): habit.id.uuidString
        case .shared(let received): "shared-" + received.key
        case .add: "add"
        }
    }
}
