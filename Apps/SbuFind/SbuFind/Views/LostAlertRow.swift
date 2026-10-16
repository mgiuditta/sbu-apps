import SbuKit
import SwiftUI

/// Avvisami se lo perdi, as in Find Air: a row with a bell and a switch, and under it what the
/// alert can and cannot do on iOS.
struct LostAlertRow: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    let model: ScanModel
    let deviceID: UUID

    @State private var isOn = false

    @ScaledMetric(relativeTo: .body) private var tileSide: CGFloat = 32

    var body: some View {
        VStack(alignment: .leading, spacing: SbuTheme.space2) {
            Toggle(isOn: $isOn) {
                HStack(spacing: SbuTheme.space3) {
                    // At the accessibility sizes the words get the whole width.
                    if !dynamicTypeSize.isAccessibilitySize {
                        Image(systemName: "bell.fill")
                            .fontWeight(.medium)
                            .imageScale(.medium)
                            .foregroundStyle(SbuTheme.onAccent)
                            .frame(width: tileSide, height: tileSide)
                            .background(.tint, in: .rect(cornerRadius: SbuTheme.radiusSm))
                            .accessibilityHidden(true)
                    }

                    Text("Avvisami se lo perdi")
                        .font(SbuTheme.body)
                        .foregroundStyle(SbuTheme.ink)
                }
            }
            .padding(.horizontal, SbuTheme.space4)
            .padding(.vertical, SbuTheme.space3)
            .background(SbuTheme.surfaceRaised, in: .rect(cornerRadius: SbuTheme.radiusLg))

            Group {
                if model.notificationsDenied {
                    Label("Per ricevere l'avviso, consenti le notifiche a Sbu Find in Impostazioni.", systemImage: "bell.slash")
                } else {
                    Text("Ti avvisa se non lo senti per 15 secondi mentre Sbu Find è aperto: iOS non lascia ascoltare i dispositivi Bluetooth ad app chiusa.")
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
        .background(SbuTheme.surface)
        .tint(SbuTheme.accentFind)
}

#Preview("Dark") {
    LostAlertRow(model: ScanModel(scanner: FixedScanner(), notifier: AcceptingLostNotifier()), deviceID: UUID())
        .padding(SbuTheme.space4)
        .background(SbuTheme.surface)
        .tint(SbuTheme.accentFind)
        .preferredColorScheme(.dark)
}
