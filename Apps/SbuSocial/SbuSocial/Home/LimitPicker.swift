import SbuKit
import SwiftUI

/// The Limite di tempo: how many minutes a day across every social, or none.
struct LimitPicker: View {
    @Bindable var usage: UsageLog

    var body: some View {
        Picker("Limite di tempo", selection: $usage.limitMinutes) {
            ForEach(UsageLog.limits, id: \.self) { minutes in
                if minutes == 0 {
                    Text("Nessuno").tag(minutes)
                } else {
                    Text(Duration.seconds(minutes * 60), format: .units(allowed: [.hours, .minutes], width: .abbreviated))
                        .tag(minutes)
                }
            }
        }
        .pickerStyle(.navigationLink)
        .font(SbuTheme.body)
        .padding(SbuTheme.space4)
        .background(SbuTheme.surfaceRaised, in: .rect(cornerRadius: SbuTheme.radiusCard))
        .overlay {
            RoundedRectangle(cornerRadius: SbuTheme.radiusCard)
                .strokeBorder(SbuTheme.line, lineWidth: SbuTheme.hairline)
        }
        .sbuAffectsFigure(usage.limitMinutes)
    }
}

#Preview("Light") {
    NavigationStack {
        LimitPicker(usage: UsageLog(defaults: UserDefaults(suiteName: "preview")!))
            .padding()
    }
}

#Preview("Dark") {
    NavigationStack {
        LimitPicker(usage: UsageLog(defaults: UserDefaults(suiteName: "preview")!))
            .padding()
    }
    .preferredColorScheme(.dark)
}
