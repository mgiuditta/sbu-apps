import SbuKit
import SwiftUI

/// Symbol and words on one line, tight, for a status in a row.
struct StatusLabelStyle: LabelStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack(spacing: SbuTheme.space1) {
            configuration.icon
            configuration.title
        }
    }
}
