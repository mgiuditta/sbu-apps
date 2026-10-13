import SbuKit
import SwiftUI

/// A row of the home's groups: the full width, sinking into `surfaceSunken` while pressed, as a
/// list row does.
struct HomeRowStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(configuration.isPressed ? SbuTheme.surfaceSunken : SbuTheme.surfaceRaised)
            .contentShape(.rect)
    }
}
