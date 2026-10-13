import SbuKit
import SwiftUI

/// A group of rows on the home, drawn like an inset grouped list section so the whole home can
/// scroll as one page: a header, then the rows on `surfaceRaised`. Put `HomeRowDivider`
/// between the rows.
struct HomeGroup<Content: View>: View {
    let title: LocalizedStringKey?
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: SbuTheme.space2) {
            if let title {
                Text(title)
                    .font(SbuTheme.footnote)
                    .foregroundStyle(SbuTheme.inkMuted)
                    .padding(.horizontal, SbuTheme.space4)
                    .accessibilityAddTraits(.isHeader)
            }

            VStack(spacing: 0) {
                content
            }
            .background(SbuTheme.surfaceRaised)
            .clipShape(.rect(cornerRadius: SbuTheme.radiusLg))
        }
    }
}

#Preview("Light") {
    HomeGroup(title: "Libera spazio") {
        Text(verbatim: "Uno").padding()
        HomeRowDivider()
        Text(verbatim: "Due").padding()
    }
    .padding()
    .background(SbuTheme.surface)
}

#Preview("Dark") {
    HomeGroup(title: nil) {
        Text(verbatim: "Uno").padding()
    }
    .padding()
    .background(SbuTheme.surface)
    .preferredColorScheme(.dark)
}
