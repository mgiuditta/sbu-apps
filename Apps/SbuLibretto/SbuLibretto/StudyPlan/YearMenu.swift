import SbuKit
import SwiftUI

/// The year filter of the study plan, as the original's "Tutti ▾" beside the title.
struct YearMenu: View {
    @Binding var selection: Int?
    let years: [Int]

    var body: some View {
        Menu {
            Picker("Anno di corso", selection: $selection) {
                Text("Tutti gli anni").tag(Int?.none)
                ForEach(years, id: \.self) { year in
                    Text("\(year)° anno").tag(Int?.some(year))
                }
            }
        } label: {
            Label("Anno di corso", systemImage: selection == nil ? "line.3.horizontal.decrease.circle" : "line.3.horizontal.decrease.circle.fill")
        }
        .accessibilityValue(selection.map { Text("\($0)° anno") } ?? Text("Tutti gli anni"))
        .accessibilityIdentifier("yearFilter")
    }
}

#Preview("Light") {
    @Previewable @State var selection: Int?
    NavigationStack {
        Text(verbatim: "")
            .toolbar {
                YearMenu(selection: $selection, years: [1, 2, 3])
            }
    }
}

#Preview("Dark") {
    @Previewable @State var selection: Int? = 2
    NavigationStack {
        Text(verbatim: "")
            .toolbar {
                YearMenu(selection: $selection, years: [1, 2])
            }
    }
    .preferredColorScheme(.dark)
}
