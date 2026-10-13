import SbuKit
import SwiftUI

/// A row of Aggiungi abitudine: the symbol in a circle, the heart for a habit linked to Salute,
/// the title. The navigation link around it adds the chevron.
struct TemplateRow: View {
    let title: LocalizedStringResource
    let symbol: String
    var linksHealth = false

    /// The circle grows with the text.
    @ScaledMetric(relativeTo: .body) private var circleSide = SbuTheme.space8

    var body: some View {
        HStack(spacing: SbuTheme.space3) {
            Image(systemName: symbol)
                .font(SbuTheme.body)
                .fontWeight(.medium)
                .imageScale(.medium)
                .foregroundStyle(SbuTheme.accentHabits)
                .frame(width: circleSide, height: circleSide)
                .background(SbuTheme.surfaceSunken, in: .circle)
                .accessibilityHidden(true)
            if linksHealth {
                Image(systemName: "heart.fill")
                    .font(SbuTheme.caption)
                    .imageScale(.medium)
                    .foregroundStyle(SbuTheme.inkMuted)
                    .accessibilityHidden(true)
            }
            Text(title)
                .foregroundStyle(SbuTheme.ink)
        }
        .accessibilityElement(children: .combine)
        .accessibilityValue(linksHealth ? Text("Collegata a Salute") : Text(verbatim: ""))
    }
}

#Preview("Light") {
    TemplateRowPreview()
}

#Preview("Dark") {
    TemplateRowPreview()
        .preferredColorScheme(.dark)
}

private struct TemplateRowPreview: View {
    var body: some View {
        NavigationStack {
            List {
                NavigationLink(value: 0) {
                    TemplateRow(title: "Personalizzata", symbol: "plus")
                }
                NavigationLink(value: 1) {
                    TemplateRow(title: "Camminare", symbol: "figure.walk", linksHealth: true)
                }
            }
        }
        .tint(SbuTheme.accentHabits)
    }
}
