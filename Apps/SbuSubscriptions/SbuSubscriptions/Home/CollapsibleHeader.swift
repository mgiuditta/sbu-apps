import SbuKit
import SwiftUI

/// A section title you tap to fold or unfold its rows, when the home groups by cycle or category.
struct CollapsibleHeader: View {
    let title: String
    let count: Int
    @Binding var isCollapsed: Bool

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        Button {
            withAnimation(SbuMotion.animation(SbuMotion.base, reduceMotion: reduceMotion)) { isCollapsed.toggle() }
        } label: {
            HStack {
                Text(title)
                Spacer()
                if isCollapsed {
                    Text(count, format: .number)
                }
                Image(systemName: "chevron.down")
                    .fontWeight(.medium)
                    .imageScale(.small)
                    .rotationEffect(.degrees(isCollapsed ? -90 : 0))
                    .accessibilityHidden(true)
            }
            .contentShape(.rect)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(title)
        .accessibilityValue(isCollapsed ? Text("Chiusa, ^[\(count) abbonamento](inflect: true)") : Text("Aperta"))
        .accessibilityHint(isCollapsed ? Text("Mostra gli abbonamenti") : Text("Nasconde gli abbonamenti"))
    }
}
