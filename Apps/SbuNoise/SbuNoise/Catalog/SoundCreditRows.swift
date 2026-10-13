import SbuKit
import SwiftUI

/// A recording's author, licence and source page, as rows of a list. The page is plain,
/// selectable text: the app opens no web page of others.
struct SoundCreditRows: View {
    let credit: SoundCredit
    /// The sentence on what CC0 means and what was done; Crediti says it once at the top.
    var showsNote = true

    var body: some View {
        LabeledContent("Registrazione", value: credit.title)
        LabeledContent("Autore", value: credit.author)
        LabeledContent("Licenza", value: credit.license)
        Text(verbatim: credit.page)
            .font(SbuTheme.footnote)
            .foregroundStyle(SbuTheme.inkMuted)
            .textSelection(.enabled)
            .accessibilityLabel(Text("Pagina della fonte: \(credit.page)"))
        if showsNote {
            Text("Registrazione in pubblico dominio (CC0), tagliata e chiusa in un loop senza stacchi.")
                .font(SbuTheme.footnote)
                .foregroundStyle(SbuTheme.inkMuted)
        }
    }
}

#Preview("Light") {
    List {
        SoundCreditRows(credit: SoundCredit(title: "rain heavy porch full steady.flac", author: "kyles", page: "https://freesound.org/people/kyles/sounds/454128/"))
    }
}

#Preview("Dark") {
    List {
        SoundCreditRows(credit: SoundCredit(title: "Fireplace.wav", author: "inchadney", page: "https://freesound.org/people/inchadney/sounds/132534/"))
    }
    .preferredColorScheme(.dark)
}
