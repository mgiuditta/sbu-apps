import Foundation
import Testing
@testable import SbuDuo

struct GiftTotalTests {
    @Test func emptyListSpendsNothing() {
        #expect(GiftTotal([]) == GiftTotal([]))
        #expect(GiftTotal([]).amount == 0)
        #expect(GiftTotal([]).count == 0)
    }

    @Test(arguments: [
        ([(Decimal(28), false), (Decimal(35), true)], Decimal(28), 1),
        ([(Decimal(10), false), (nil, false)], Decimal(10), 2),
        ([(Decimal(string: "79.90")!, false), (Decimal(string: "0.10")!, false)], Decimal(80), 2),
        ([(Decimal(50), true), (nil, true)], Decimal(0), 0),
    ] as [([(Decimal?, Bool)], Decimal, Int)])
    func sumsOnlyGiftsStillToBuy(gifts: [(Decimal?, Bool)], amount: Decimal, count: Int) {
        let total = GiftTotal(gifts.map { (price: $0.0, isBought: $0.1) })
        #expect(total.amount == amount)
        #expect(total.count == count)
    }
}
