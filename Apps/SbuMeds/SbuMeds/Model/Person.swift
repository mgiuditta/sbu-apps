import Foundation
import SwiftData

/// Someone whose medicines you look after on this iPhone: you, a child, a parent.
/// Medisafe's dependents, free and without an account.
@Model
final class Person {
    var id = UUID()
    var name = ""
    /// Your order in the people list.
    var order = 0
    var createdAt = Date.now

    @Relationship(deleteRule: .cascade, inverse: \Medicine.person) var medicines: [Medicine]? = []

    init(name: String, order: Int) {
        self.name = name
        self.order = order
    }

    var medicineList: [Medicine] {
        (medicines ?? []).sorted { $0.createdAt < $1.createdAt }
    }
}
