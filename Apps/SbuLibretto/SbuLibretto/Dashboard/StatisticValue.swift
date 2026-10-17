import SwiftUI

/// One row of a card on the tool screen: a secondary figure, or the credits with their bar.
struct StatisticValue: Identifiable {
    let id: String
    let title: LocalizedStringKey
    let value: String
}
