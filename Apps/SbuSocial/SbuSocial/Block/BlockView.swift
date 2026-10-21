import FamilyControls
import SbuKit
import SwiftUI

/// The Blocco tab: how many native apps the Shield covers, the switch, and the app picker.
/// Screen Time is asked for only when you first choose the apps.
struct BlockView: View {
    @Environment(ShieldModel.self) private var shield
    @State private var isPicking = false
    @State private var picked = FamilyActivitySelection()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: SbuTheme.space6) {
                SbuScreenTitle("Blocco", cartiglio: Cartiglio.today)
                if shield.settings.selection == FamilyActivitySelection() {
                    SbuEmpty(sentence: "Scegli le app da schermare: le apri qui, senza video brevi.") {
                        Button("Scegli le app", action: pick)
                    }
                } else {
                    SbuFigure(value: shield.settings.appCount.formatted(), fullStop: shield.settings.isOn ? .set : .waiting,
                              context: Text("app schermate"))
                    ShieldControls(shield: shield, pick: pick)
                }
            }
            .padding(SbuTheme.space4)
            .frame(maxWidth: .infinity, alignment: .topLeading)
        }
        .sbuPaper(grid: true)
        .familyActivityPicker(isPresented: $isPicking, selection: $picked)
        .onChange(of: isPicking) {
            if !isPicking { shield.choose(picked) }
        }
    }

    private func pick() {
        Task {
            guard await shield.authorize() else { return }
            picked = shield.settings.selection
            isPicking = true
        }
    }
}

#Preview("Light") {
    NavigationStack {
        BlockView()
    }
    .environment(ShieldModel(defaults: UserDefaults(suiteName: "preview")!))
}

#Preview("Dark") {
    NavigationStack {
        BlockView()
    }
    .environment(ShieldModel(defaults: UserDefaults(suiteName: "preview")!))
    .preferredColorScheme(.dark)
}
