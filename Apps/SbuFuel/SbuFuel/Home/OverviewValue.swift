import SwiftUI

/// One secondary figure of the tool screen: its name, the value, and the value in words for VoiceOver.
struct OverviewValue: Identifiable {
    let id: String
    let title: LocalizedStringKey
    let value: String
    /// The value in full words for VoiceOver, when its unit is an abbreviation such as "mpg".
    var spokenValue: String?
}
