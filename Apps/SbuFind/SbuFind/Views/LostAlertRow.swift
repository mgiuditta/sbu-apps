import SbuKit
import SwiftUI

/// Avvisami se lo perdi, as in Find Air: a row with a bell and a switch, and under it what the
/// alert can and cannot do on iOS. The switch takes the shell's `SbuToggleStyle`.
struct LostAlertRow: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    let model: ScanModel
    let deviceID: UUID

    @State private var isOn = false

    var body: some View {
        VStack(alignment: .leading, spacing: SbuTheme.space2) {
            Toggle(isOn: $isOn) {
                HStack(spacing: SbuTheme.space3) {
                    // At the accessibility sizes the words get the whole width.
                    if !dynamicTypeSize.isAccessibilitySize {
                        Image(systemName: "bell")
                            .fontWeight(.medium)
                            .imageScale(.medium)
                            .foregroundStyle(SbuTheme.ink)
                            .accessibilityHidden(true)
                    }

                    Text("Avvisami se lo perdi")
                        .font(SbuTheme.body)
                        .foregroundStyle(SbuTheme.ink)
                }
            }
            .padding(.horizontal, SbuTheme.space4)
            .padding(.vertical, SbuTheme.space3)
            .background(SbuTheme.surfaceRaised, in: .rect(cornerRadius: SbuTheme.radiusCard))

            VStack(alignment: .leading, spacing: SbuTheme.space1) {
                if model.notificationsDenied {
                    Label("Per ricevere l'avviso, consenti le notifiche a Sbu Find in Impostazioni.", systemImage: "bell.slash")
                } else if canWatchInBackground {
                    Label("Anche con l'app chiusa", systemImage: "checkmark.circle")
                        .foregroundStyle(SbuTheme.ink)
                    Text("Ti avvisa se non lo senti per \(foregroundSeconds) secondi con l'app aperta, \(backgroundSeconds) secondi con l'app chiusa. Se chiudi Sbu Find dal selettore delle app, si ferma tutto.")
                } else {
                    Label("Solo con l'app aperta", systemImage: "iphone")
                        .foregroundStyle(SbuTheme.ink)
                    Text("Ti avvisa se non lo senti per \(foregroundSeconds) secondi mentre Sbu Find è aperto. Con l'app chiusa iOS ascolta solo i tuoi dispositivi che trasmettono un servizio Bluetooth, e quasi mai gli AirPods.")
                }
            }
            .font(SbuTheme.footnote)
            .foregroundStyle(SbuTheme.inkMuted)
            .padding(.horizontal, SbuTheme.space4)
        }
        .onAppear(perform: syncFromModel)
        .onChange(of: isOn, switched)
        .onChange(of: model.watchedID, syncFromModel)
    }

    private var canWatchInBackground: Bool {
        model.canWatchInBackground(deviceID)
    }

    private var foregroundSeconds: Int {
        Int(SignalTuning.current.lostAlertForeground)
    }

    private var backgroundSeconds: Int {
        Int(SignalTuning.current.lostAlertBackground)
    }

    private func syncFromModel() {
        isOn = model.watchedID == deviceID
    }

    private func switched() {
        let isWatching = model.watchedID == deviceID
        guard isOn != isWatching else { return }
        if isOn {
            Task {
                await model.watch(deviceID)
                syncFromModel()
            }
        } else {
            model.stopWatching()
        }
    }
}

#Preview("Light") {
    LostAlertRow(model: ScanModel(scanner: FixedScanner(), notifier: AcceptingLostNotifier()), deviceID: UUID())
        .padding(SbuTheme.space4)
        .sbuPaper(grid: false)
        .toggleStyle(SbuToggleStyle())
        .tint(SbuTheme.ink)
}

#Preview("Dark") {
    LostAlertRow(model: ScanModel(scanner: FixedScanner(), notifier: AcceptingLostNotifier()), deviceID: UUID())
        .padding(SbuTheme.space4)
        .sbuPaper(grid: false)
        .toggleStyle(SbuToggleStyle())
        .tint(SbuTheme.ink)
        .preferredColorScheme(.dark)
}
