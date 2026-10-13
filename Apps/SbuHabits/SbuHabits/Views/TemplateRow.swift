import SbuKit
import SwiftUI

/// A row of Aggiungi abitudine: the symbol in a circle, the heart for a habit linked to Salute,
/// the title, and in the search results the detail that tells same-titled Modelli apart. The
/// navigation link around it adds the chevron.
struct TemplateRow: View {
    let title: LocalizedStringResource
    let symbol: String
    var linksHealth = false
    /// The line under the title; it also says the Salute link, so VoiceOver reads it once.
    var detail: LocalizedStringResource?

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    /// The circle grows with the text.
    @ScaledMetric(relativeTo: .body) private var circleSide = SbuTheme.space8

    /// At the accessibility sizes the symbol goes above the title, so the title has the whole
    /// row and no word breaks in half.
    private var layout: AnyLayout {
        dynamicTypeSize.isAccessibilitySize
            ? AnyLayout(VStackLayout(alignment: .leading, spacing: SbuTheme.space2))
            : AnyLayout(HStackLayout(spacing: SbuTheme.space3))
    }

    var body: some View {
        layout {
            HStack(spacing: SbuTheme.space3) {
                Image(systemName: symbol)
                    .font(SbuTheme.body)
                    .fontWeight(.medium)
                    .imageScale(.medium)
                    .foregroundStyle(SbuTheme.accentHabits)
                    .frame(width: circleSide, height: circleSide)
                    .background(SbuTheme.surfaceSunken, in: .circle)
                if linksHealth {
                    Image(systemName: "heart.fill")
                        .font(SbuTheme.caption)
                        .imageScale(.medium)
                        .foregroundStyle(SbuTheme.inkMuted)
                }
            }
            .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: SbuTheme.space1) {
                Text(title)
                    .foregroundStyle(SbuTheme.ink)
                if let detail {
                    Text(detail)
                        .font(SbuTheme.subheadline)
                        .foregroundStyle(SbuTheme.inkMuted)
                }
            }
        }
        // Past the second accessibility size a long word such as "Personalizzata" no longer fits
        // the row even alone on its line, and iOS would break it in half.
        .dynamicTypeSize(...DynamicTypeSize.accessibility2)
        .accessibilityElement(children: .combine)
        .accessibilityValue(linksHealth && detail == nil ? Text("Collegata a Salute") : Text(verbatim: ""))
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
