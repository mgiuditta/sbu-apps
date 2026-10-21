import FamilyControls
import SbuKit
import SwiftUI

/// The Sonno tab: how long the night without social lasts, its hours and days, and focus sessions.
struct SleepView: View {
    @Environment(ShieldModel.self) private var shield

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: SbuTheme.space6) {
                SbuScreenTitle("Sonno", cartiglio: Cartiglio.today)
                if shield.settings.selection == FamilyActivitySelection() {
                    SbuEmpty(sentence: "Scegli prima le app in Blocco: di notte si chiudono da sole.") {
                        EmptyView()
                    }
                } else {
                    SbuFigure(value: shield.sleep.duration.formatted(.units(allowed: [.hours, .minutes], width: .narrow)),
                              fullStop: shield.sleep.isOn ? .set : .waiting,
                              context: Text(shield.sleep.isOn ? "di notte senza social" : "di notte, se attivi il Sonno"))
                    SleepControls(shield: shield)
                    FocusCard(shield: shield)
                }
            }
            .padding(SbuTheme.space4)
            .frame(maxWidth: .infinity, alignment: .topLeading)
        }
        .sbuPaper(grid: true)
    }
}

#Preview("Light") {
    NavigationStack {
        SleepView()
    }
    .environment(ShieldModel(defaults: UserDefaults(suiteName: "preview")!))
}

#Preview("Dark") {
    NavigationStack {
        SleepView()
    }
    .environment(ShieldModel(defaults: UserDefaults(suiteName: "preview")!))
    .preferredColorScheme(.dark)
}
