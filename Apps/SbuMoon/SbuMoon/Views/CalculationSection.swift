import SbuKit
import SwiftUI

/// Settings section that says how the moon is worked out, and in which time zone the times are.
struct CalculationSection: View {
    var body: some View {
        Section {
            LabeledContent("Fuso orario") {
                Text(TimeZone.current.localizedName(for: .generic, locale: .current) ?? TimeZone.current.identifier)
                    .foregroundStyle(SbuTheme.inkMuted)
            }
        } header: {
            Text("Calcolo")
        } footer: {
            Text("Fasi, sorgere e tramonto calcolati su questo iPhone con gli algoritmi di Jean Meeus, senza rete. Gli orari hanno un errore di qualche minuto.")
        }
    }
}

#Preview("Light") {
    Form { CalculationSection() }
}

#Preview("Dark") {
    Form { CalculationSection() }
        .preferredColorScheme(.dark)
}
