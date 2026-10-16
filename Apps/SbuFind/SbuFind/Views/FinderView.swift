import SbuKit
import SwiftUI

/// The search for one device, as in Find Air: the name as a large title, a hint to move,
/// Avvisami se lo perdi, a large ring around the device's symbol, and the signal as the one
/// figure under it.
///
/// It celebrates the "found it" moment with a strong tap and a pop of the ring, and ticks faster
/// as the device gets closer.
struct FinderView: View {
    let model: ScanModel
    let ringer: HeadphoneRinger
    let deviceID: UUID

    @State private var ticker = ProximityTicker()

    /// Your name for the device if it is one of yours, else the one it advertises.
    private var title: String {
        guard let device = model.tracked?.device else { return String(localized: "Senza nome") }
        return model.savedDevice(forDeviceID: device.id)?.name ?? device.name ?? String(localized: "Senza nome")
    }

    /// Fai suonare for headphones and earbuds, or whenever some are connected.
    private var showsRing: Bool {
        guard ringer.headphones == nil else { return true }
        let kind = model.tracked?.device.kind
        return kind == .earbuds || kind == .headphones
    }

    var body: some View {
        // At least as tall as the screen, so the pills sit at the bottom; scrolling only at the
        // largest text sizes.
        GeometryReader { proxy in
            ScrollView {
                VStack(spacing: SbuTheme.space6) {
                    Text("Muoviti per far crescere il segnale")
                        .font(SbuTheme.body)
                        .foregroundStyle(SbuTheme.inkMuted)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    if let device = model.tracked?.device, let probable = model.probableSavedDevice(forDeviceID: device.id) {
                        Label("Forse è \(probable.name): ha lo stesso nome, ma un altro dispositivo può dire lo stesso.", systemImage: "questionmark.circle")
                            .font(SbuTheme.footnote)
                            .foregroundStyle(SbuTheme.inkMuted)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    LostAlertRow(model: model, deviceID: deviceID)

                    FinderRing(tracked: model.tracked, foundMoments: model.foundMoments)
                        .frame(maxWidth: min(proxy.size.width * 0.66, 280))

                    FinderFigure(tracked: model.tracked)

                    // Only while the device is not heard: then the place is where to go back to.
                    if let tracked = model.tracked, tracked.isLost, let sighting = model.sighting(for: tracked.device) {
                        LastSeenCard(sighting: sighting)
                    }

                    if showsRing {
                        RingCard(ringer: ringer)
                    }

                    if model.tracked?.device.kind == .earbuds {
                        NavigationLink {
                            AirPodGuideView()
                        } label: {
                            Label("Hai perso un solo auricolare?", systemImage: "airpod.right")
                                .font(SbuTheme.subheadline)
                                .frame(maxWidth: .infinity, minHeight: SbuTheme.controlRoundSm, alignment: .leading)
                                .contentShape(.rect)
                        }
                    }

                    Spacer(minLength: 0)

                    // In one row, wrapping onto two at the largest text sizes, so no word is cut.
                    PillsLayout(spacing: SbuTheme.space2) {
                        FeedbackPills(model: model)
                    }
                }
                .padding(.horizontal, SbuTheme.space4)
                .padding(.bottom, SbuTheme.space8)
                .frame(minHeight: proxy.size.height, alignment: .top)
            }
            .scrollBounceBehavior(.basedOnSize)
        }
        .background(SbuTheme.surface)
        .navigationTitle(Text(verbatim: title))
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            if let device = model.tracked?.device {
                ToolbarItem(placement: .topBarTrailing) {
                    MyDeviceMenu(model: model, device: device)
                }
            }
        }
        .overlay {
            if let notice = BluetoothNotice(state: model.state) {
                BluetoothNoticeView(notice: notice)
            }
        }
        .sensoryFeedback(.success, trigger: model.foundMoments)
        .sensoryFeedback(.warning, trigger: model.lostAlerts)
        .onAppear(perform: startTracking)
        .onDisappear(perform: leave)
        .task {
            await tickUntilCancelled()
        }
    }

    private func startTracking() {
        model.track(deviceID)
    }

    /// Leaving the finder stops following the device and any ringing.
    private func leave() {
        model.stopTracking()
        ringer.stop()
    }

    /// Ticks with the latest proximity, waiting the gap it gives; checks again often while
    /// silent or switched off, so a switch turned on starts ticking at once.
    private func tickUntilCancelled() async {
        ticker.prepare()
        while !Task.isCancelled {
            var gap = ProximityCue.slowest / 5
            if ProximityCue.shouldTick(tracked: model.tracked, playsSound: model.playsSound, vibrates: model.vibrates),
               let proximity = model.tracked?.device.proximity {
                ticker.tick(proximity: proximity, playsSound: model.playsSound, vibrates: model.vibrates)
                gap = ProximityCue.interval(for: proximity)
            }
            try? await Task.sleep(for: gap)
        }
    }
}

#Preview("Light") {
    FinderPreview()
}

#Preview("Dark") {
    FinderPreview()
        .preferredColorScheme(.dark)
}

private struct FinderPreview: View {
    @State private var model = ScanModel(scanner: FixedScanner(), notifier: AcceptingLostNotifier(), location: FixedLocationProvider())
    @State private var ringer = HeadphoneRinger(route: FixedAudio(), player: FixedAudio())

    var body: some View {
        NavigationStack {
            FinderView(model: model, ringer: ringer, deviceID: FixedScanner.demoDevices[0].id)
                .task { await model.run() }
        }
        .tint(SbuTheme.accentFind)
    }
}
