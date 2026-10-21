import SbuKit
import SwiftUI

/// One square per Platform, as many per row as fit.
struct PlatformGrid: View {
    let open: (Platform) -> Void

    var body: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: SbuTheme.gridCell * 4), spacing: SbuTheme.space3)],
                  spacing: SbuTheme.space3) {
            ForEach(Platform.allCases) { platform in
                Button {
                    open(platform)
                } label: {
                    Text(verbatim: platform.name)
                        .font(SbuTheme.headline)
                        .foregroundStyle(SbuTheme.ink)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity, minHeight: SbuTheme.gridCell * 2)
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
        PlatformGrid { _ in }
            .padding()
    }
}

#Preview("Dark") {
    NavigationStack {
        PlatformGrid { _ in }
            .padding()
    }
    .preferredColorScheme(.dark)
}
