import Foundation
import SwiftData

/// A gift idea for someone: the Regali cover's one kind of record. Local only, never synced.
@Model
final class Gift {
    var person: String
    var idea: String
    var price: Decimal?
    var occasion: Date?
    var isBought: Bool
    var createdAt: Date

    init(person: String, idea: String, price: Decimal? = nil, occasion: Date? = nil, isBought: Bool = false, createdAt: Date = .now) {
        self.person = person
        self.idea = idea
        self.price = price
        self.occasion = occasion
        self.isBought = isBought
        self.createdAt = createdAt
    }
}
