import SbuKit
import SwiftUI

/// One square per Platform, as many per row as fit.
struct PlatformGrid: View {
    var body: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: SbuTheme.gridCell * 5), spacing: SbuTheme.space3)],
                  spacing: SbuTheme.space3) {
            ForEach(Platform.allCases) { platform in
                NavigationLink(value: platform) {
                    Text(verbatim: platform.name)
                        .font(SbuTheme.headline)
                        .foregroundStyle(SbuTheme.ink)
                        .frame(maxWidth: .infinity, minHeight: SbuTheme.gridCell * 3)
                        .padding(SbuTheme.space3)
                        .background(SbuTheme.surfaceRaised, in: .rect(cornerRadius: SbuTheme.radiusCard))
                        .overlay {
                            RoundedRectangle(cornerRadius: SbuTheme.radiusCard)
                                .strokeBorder(SbuTheme.line, lineWidth: 1)
                        }
                }
                .buttonStyle(.plain)
            }
        }
    }
}

#Preview("Light") {
    NavigationStack {
        PlatformGrid()
            .padding()
    }
}

#Preview("Dark") {
    NavigationStack {
        PlatformGrid()
            .padding()
    }
    .preferredColorScheme(.dark)
}
