import FamilyControls
import SbuKit
import SwiftUI

/// Sonno's switch, bedtime and waking, the margin, the nights and the apps left open.
struct SleepControls: View {
    @Bindable var shield: ShieldModel
    @State private var isPickingExcluded = false
    @State private var excluded = FamilyActivitySelection()

    var body: some View {
        VStack(alignment: .leading, spacing: SbuTheme.space4) {
            Toggle("Sonno attivo", isOn: $shield.sleep.isOn)
                .sbuAffectsFigure(shield.sleep.isOn)
            Divider()
            DatePicker("A letto", selection: $shield.sleep.bedtimeDate, displayedComponents: .hourAndMinute)
                .sbuAffectsFigure(shield.sleep.bedtime)
            DatePicker("Sveglia", selection: $shield.sleep.wakeDate, displayedComponents: .hourAndMinute)
                .sbuAffectsFigure(shield.sleep.wake)
            Picker("Margine", selection: $shield.sleep.margin) {
                ForEach(SleepSettings.margins, id: \.self) { minutes in
                    if minutes == 0 {
                        Text("Nessuno").tag(minutes)
                    } else {
                        Text(Duration.seconds(minutes * 60), format: .units(allowed: [.hours, .minutes], width: .abbreviated)).tag(minutes)
                    }
                }
            }
            Divider()
            NightsPicker(days: $shield.sleep.days)
            Divider()
            Button("App escluse: \(shield.sleep.excluded.applicationTokens.count)") {
                excluded = shield.sleep.excluded
                isPickingExcluded = true
            }
            Text("Restano aperte di notte, per esempio i messaggi di famiglia.")
                .font(SbuTheme.footnote)
                .foregroundStyle(SbuTheme.inkMuted)
        }
        .font(SbuTheme.body)
        .padding(SbuTheme.space4)
        .background(SbuTheme.surfaceRaised, in: .rect(cornerRadius: SbuTheme.radiusCard))
        .overlay {
            RoundedRectangle(cornerRadius: SbuTheme.radiusCard)
                .strokeBorder(SbuTheme.line, lineWidth: SbuTheme.hairline)
        }
        .familyActivityPicker(isPresented: $isPickingExcluded, selection: $excluded)
        .onChange(of: isPickingExcluded) {
            if !isPickingExcluded { shield.sleep.excluded = excluded }
        }
    }
}

#Preview("Light") {
    SleepControls(shield: ShieldModel(defaults: UserDefaults(suiteName: "preview")!))
        .padding()
}

#Preview("Dark") {
    SleepControls(shield: ShieldModel(defaults: UserDefaults(suiteName: "preview")!))
        .padding()
        .preferredColorScheme(.dark)
}
