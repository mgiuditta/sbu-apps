import SbuKit
import SwiftUI

/// What an empty inventory or folder says, and the way to fill it.
/// The empty inventory also offers a sample house, which goes with one delete.
///
/// Laid out by hand rather than with `ContentUnavailableView`, so the buttons keep `SbuButton`'s full width.
struct EmptyFolderView: View {
    let isTop: Bool
    let add: () -> Void
    let addSample: () -> Void

    var body: some View {
        // Centred when it fits, scrolling at the largest text sizes when it doesn't.
        GeometryReader { proxy in
            ScrollView {
                VStack(spacing: SbuTheme.space6) {
                    VStack(spacing: SbuTheme.space2) {
                        Image(systemName: isTop ? "shippingbox" : "folder")
                            .font(SbuTheme.largeTitle)
                            .fontWeight(.medium)
                            .foregroundStyle(SbuTheme.inkMuted)
                            .accessibilityHidden(true)
                        Text(isTop ? "Inventario vuoto" : "Cartella vuota")
                            .font(SbuTheme.title2)
                            .foregroundStyle(SbuTheme.ink)
                            .accessibilityAddTraits(.isHeader)
                        Text(isTop
                             ? "Aggiungi le cose che hai, con una foto, dove sono e quante."
                             : "Aggiungi qui gli oggetti o le cartelle che contiene.")
                            .font(SbuTheme.body)
                            .foregroundStyle(SbuTheme.inkMuted)
                    }
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)

                    VStack(spacing: SbuTheme.space3) {
                        SbuButton("Aggiungi oggetto", action: add)
                            .accessibilityIdentifier("addFirst")
                        if isTop {
                            SbuButton("Prova con un esempio", kind: .secondary, action: addSample)
                                .accessibilityIdentifier("addSample")
                        }
                    }
                }
                .padding(SbuTheme.space4)
                .frame(maxWidth: .infinity, minHeight: proxy.size.height)
            }
            .scrollBounceBehavior(.basedOnSize)
        }
    }
}

#Preview("Light") {
    EmptyFolderView(isTop: true, add: {}, addSample: {})
        .background(SbuTheme.surface)
        .tint(SbuTheme.accentInventory)
}

#Preview("Dark") {
    EmptyFolderView(isTop: false, add: {}, addSample: {})
        .background(SbuTheme.surface)
        .tint(SbuTheme.accentInventory)
        .preferredColorScheme(.dark)
}
