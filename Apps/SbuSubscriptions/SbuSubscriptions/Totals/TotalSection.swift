import SwiftUI

/// Settings → whether the home figure totals a year or a month.
struct TotalSection: View {
    @AppStorage(TotalPeriod.storageKey, store: .appGroup) private var period = TotalPeriod.year

    var body: some View {
        Section {
            Picker("Totale", selection: $period) {
                Text("All'anno").tag(TotalPeriod.year)
                Text("Al mese").tag(TotalPeriod.month)
            }
        } footer: {
            Text("La cifra in alto e il widget mostrano questo periodo.")
        }
    }
}

#Preview("Light") {
    Form { TotalSection() }
}

#Preview("Dark") {
    Form { TotalSection() }
        .preferredColorScheme(.dark)
}
