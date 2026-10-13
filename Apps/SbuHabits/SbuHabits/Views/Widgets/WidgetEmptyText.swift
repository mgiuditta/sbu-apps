import SbuKit
import SwiftUI

/// What a widget says when there is no habit to show.
struct WidgetEmptyText: View {
    var body: some View {
        Text("Aggiungi un'abitudine nell'app")
            .font(SbuTheme.footnote)
            .foregroundStyle(SbuTheme.inkMuted)
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview("Light") {
    WidgetEmptyText()
        .frame(width: 138, height: 138)
        .background(SbuTheme.surface)
}

#Preview("Dark") {
    WidgetEmptyText()
        .frame(width: 138, height: 138)
        .background(SbuTheme.surface)
        .preferredColorScheme(.dark)
}
