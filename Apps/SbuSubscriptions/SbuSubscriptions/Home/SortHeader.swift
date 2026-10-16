import SbuKit
import SwiftUI

/// The header of the active subscriptions: its title, and on the right the order they're in, which a tap changes.
struct SortHeader: View {
    let title: String
    @Binding var sort: HomeSort

    var body: some View {
        HStack {
            Text(title)
                .accessibilityAddTraits(.isHeader)
            Spacer()
            Menu {
                Picker("Ordina per", selection: $sort) {
                    Text("Prossimo pagamento").tag(HomeSort.nextPayment)
                    Text("Prezzo al mese").tag(HomeSort.monthlyPrice)
                    Text("Nome").tag(HomeSort.name)
                }
            } label: {
                HStack(spacing: SbuTheme.space1) {
                    Text(shortName)
                    Image(systemName: "arrow.up.arrow.down")
                        .fontWeight(.medium)
                        .imageScale(.medium)
                }
                .frame(minHeight: 44)
                .contentShape(.rect)
            }
            .tint(SbuTheme.inkMuted)
            .accessibilityLabel(Text("Ordina per"))
            .accessibilityValue(Text(shortName))
            .accessibilityIdentifier("sort")
        }
        .textCase(nil)
    }

    private var shortName: LocalizedStringKey {
        switch sort {
        case .nextPayment: "Prossimo"
        case .monthlyPrice: "Prezzo"
        case .name: "Nome"
        }
    }
}

#Preview("Light") {
    @Previewable @State var sort = HomeSort.nextPayment
    List {
        Section {
            Text(verbatim: "Musica")
        } header: {
            SortHeader(title: "Attivi", sort: $sort)
        }
    }
}

#Preview("Dark") {
    @Previewable @State var sort = HomeSort.monthlyPrice
    List {
        Section {
            Text(verbatim: "Musica")
        } header: {
            SortHeader(title: "Attivi", sort: $sort)
        }
    }
    .preferredColorScheme(.dark)
}
