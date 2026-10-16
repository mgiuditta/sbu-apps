import SbuKit
import SwiftUI

/// Which exams to show and in what order: taken or still to take, then date, grade or credits,
/// with the arrow beside it that turns the order around, as the original's arrow on the chosen chip.
/// A new order starts from the newest, highest or largest.
struct PlanControls: View {
    @Binding var query: PlanQuery

    var body: some View {
        Section {
            Picker("Mostra", selection: $query.status) {
                ForEach(PlanStatus.allCases) { status in
                    Text(status.title).tag(status)
                }
            }
            .pickerStyle(.segmented)
            .accessibilityIdentifier("planStatus")
            HStack(spacing: SbuTheme.space2) {
                Picker("Ordina per", selection: $query.sort) {
                    ForEach(PlanSort.allCases) { sort in
                        Text(sort.title).tag(sort)
                    }
                }
                .pickerStyle(.segmented)
                .accessibilityIdentifier("planSort")
                Button(query.descending ? "Ordine decrescente" : "Ordine crescente",
                       systemImage: query.descending ? "arrow.down" : "arrow.up", action: flip)
                    .labelStyle(.iconOnly)
                    .fontWeight(.medium)
                    .frame(minWidth: SbuTheme.controlRoundSm, minHeight: SbuTheme.controlRoundSm)
                    .contentShape(.rect)
                    .accessibilityIdentifier("planDirection")
            }
        }
        .listRowInsets(EdgeInsets(top: SbuTheme.space1, leading: 0, bottom: SbuTheme.space1, trailing: 0))
        .listRowBackground(Color.clear)
        .listRowSeparator(.hidden)
        .onChange(of: query.sort) {
            query.descending = true
        }
    }

    private func flip() {
        query.descending.toggle()
    }
}

#Preview("Light") {
    @Previewable @State var query = PlanQuery()
    List {
        PlanControls(query: $query)
    }
    .tint(SbuTheme.accentLibretto)
}

#Preview("Dark") {
    @Previewable @State var query = PlanQuery(status: .pending, sort: .credits, descending: false)
    List {
        PlanControls(query: $query)
    }
    .tint(SbuTheme.accentLibretto)
    .preferredColorScheme(.dark)
}
