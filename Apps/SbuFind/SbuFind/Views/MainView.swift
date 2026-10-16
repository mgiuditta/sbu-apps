import SbuKit
import SwiftUI

/// The nearby devices, strongest signal first; or why Bluetooth cannot scan.
///
/// As in Find Air: settings at the top left, help at the top right, the list. As in Wunderfind:
/// your devices on top, then Altri dispositivi with the system spinner while the scan runs. The
/// scan never stops while the app is open; pulling the list down, or Cerca di nuovo when nothing
/// is near, forgets the list and listens from scratch.
struct MainView: View {
    @Environment(\.showSettings) private var showSettings
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    let model: ScanModel
    let ringer: HeadphoneRinger

    @State private var isShowingHelp = false

    private var isScanning: Bool {
        model.state == .ready
    }

    /// Nothing nearby once the first seconds of the scan are over.
    private var isNothingNearby: Bool {
        isScanning && !model.isSettling && model.devices.isEmpty && model.hiddenUnnamedCount == 0
    }

    var body: some View {
        List {
            // Yours first, as in Wunderfind; one card per device, as in Find Air.
            ForEach(model.myDevices) { saved in
                Section {
                    MyDeviceLink(saved: saved, match: model.myMatches[saved.id])
                        .listRowBackground(SbuTheme.surfaceRaised)
                } header: {
                    if saved.id == model.myDevices.first?.id {
                        Text("I miei dispositivi")
                    }
                }
            }

            ForEach(model.devices) { device in
                Section {
                    NavigationLink(value: device.id) {
                        DeviceRow(device: device)
                    }
                    .listRowBackground(SbuTheme.surfaceRaised)
                } header: {
                    if device.id == model.devices.first?.id {
                        NearbyHeader(isScanning: isScanning)
                    }
                }
            }

            if isScanning, model.devices.isEmpty {
                Section {
                    if isNothingNearby {
                        NothingNearbyRow(searchAgain: model.rescan)
                    } else {
                        Text("Ricerca dei dispositivi vicini…")
                            .font(SbuTheme.body)
                            .foregroundStyle(SbuTheme.inkMuted)
                    }
                } header: {
                    NearbyHeader(isScanning: isScanning)
                }
                .listRowBackground(SbuTheme.surfaceRaised)
            }

            if model.hiddenUnnamedCount > 0 {
                Section {
                } footer: {
                    Text("Dispositivi senza nome nascosti: \(model.hiddenUnnamedCount). Puoi mostrarli in Impostazioni.")
                        .font(SbuTheme.footnote)
                        .foregroundStyle(SbuTheme.inkMuted)
                }
            }

            if model.remembersPlaces, !model.recentSightings.isEmpty {
                Section("Sentiti prima") {
                    ForEach(model.recentSightings) { sighting in
                        NavigationLink(value: sighting.id) {
                            SightingRow(sighting: sighting)
                        }
                    }
                }
                .listRowBackground(SbuTheme.surfaceRaised)
            }
        }
        .listStyle(.insetGrouped)
        .listSectionSpacing(SbuTheme.space3)
        .scrollContentBackground(.hidden)
        // Rows slide in and reorder as the signals change; still with Reduce Motion.
        .animation(reduceMotion ? nil : .smooth, value: model.devices.map(\.id))
        .navigationTitle("Sbu Find")
        .navigationBarTitleDisplayMode(.large)
        .navigationDestination(for: UUID.self) { id in
            FinderView(model: model, ringer: ringer, deviceID: id)
        }
        .refreshable(action: searchAgain)
        .overlay {
            if let notice = BluetoothNotice(state: model.state) {
                BluetoothNoticeView(notice: notice)
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                // In the accent, as in Find Air: this screen has no figure and no full stop.
                Button("Impostazioni", systemImage: "gearshape", action: showSettings.callAsFunction)
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button("Aiuto", systemImage: "questionmark.circle", action: showHelp)
            }
        }
        .sheet(isPresented: $isShowingHelp) {
            HelpView()
        }
    }
}

private extension MainView {
    func showHelp() {
        isShowingHelp = true
    }

    /// Pull to refresh: listens from scratch and gives the scan a moment before the spinner goes.
    func searchAgain() async {
        model.rescan()
        try? await Task.sleep(for: .seconds(1))
    }
}

#Preview("Light") {
    MainViewPreview(scanner: FixedScanner())
}

#Preview("Dark") {
    MainViewPreview(scanner: FixedScanner())
        .preferredColorScheme(.dark)
}

#Preview("Bluetooth spento") {
    MainViewPreview(scanner: FixedScanner(state: .poweredOff))
}

#Preview("Nessun dispositivo") {
    MainViewPreview(scanner: FixedScanner(devices: []))
}

private struct MainViewPreview: View {
    @State private var model: ScanModel

    @State private var ringer = HeadphoneRinger(route: FixedAudio(), player: FixedAudio())

    init(scanner: FixedScanner) {
        _model = State(initialValue: ScanModel(scanner: scanner, notifier: AcceptingLostNotifier(), location: FixedLocationProvider()))
    }

    var body: some View {
        NavigationStack {
            MainView(model: model, ringer: ringer)
                .task { await model.run() }
        }
    }
}
