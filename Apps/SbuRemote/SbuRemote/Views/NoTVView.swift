import SbuKit
import SwiftUI

/// The tool screen before the first TV: the title, then the "0" waiting for a TV, what the app
/// needs, and the one button that starts the search. On gridded paper, scrolling only when the
/// text is too large to fit.
struct NoTVView: View {
    let onAdd: () -> Void

    /// "Sbu · Telecomando · Nessuna TV".
    private var cartiglio: String {
        ["Sbu", String(localized: "Telecomando"), String(localized: "Nessuna TV")].joined(separator: " · ")
    }

    var body: some View {
        GeometryReader { proxy in
            ScrollView {
                VStack(alignment: .leading, spacing: SbuTheme.space6) {
                    SbuScreenTitle("Telecomando", cartiglio: cartiglio)
                    SbuEmpty(sentence: "Accendi la TV e collega il telefono alla stessa Wi-Fi. Sbu Remote la cerca e la comanda da qui.") {
                        Button("Cerca la TV", systemImage: "magnifyingglass", action: onAdd)
                            .buttonStyle(.bordered)
                    }
                }
                .padding(SbuTheme.space4)
                .frame(maxWidth: .infinity, minHeight: proxy.size.height, alignment: .top)
                // Inside the scroll, so the grid and the figure's baseline move together.
                .sbuPaper(grid: true)
            }
            .scrollBounceBehavior(.basedOnSize)
        }
        .background(SbuTheme.paper)
    }
}

#Preview("Light") {
    NavigationStack {
        NoTVView {}
    }
    .tint(SbuTheme.ink)
}

#Preview("Dark") {
    NavigationStack {
        NoTVView {}
    }
    .tint(SbuTheme.ink)
    .preferredColorScheme(.dark)
}
