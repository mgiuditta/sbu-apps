import Foundation

/// What is still to spend: the sum of the prices of the gifts not bought yet.
nonisolated struct GiftTotal: Equatable {
    let amount: Decimal
    /// Gifts not bought yet, priced or not.
    let count: Int

    init(_ gifts: [(price: Decimal?, isBought: Bool)]) {
        let open = gifts.filter { !$0.isBought }
        amount = open.compactMap(\.price).reduce(0, +)
        count = open.count
    }
}
