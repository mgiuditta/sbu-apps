import SbuKit
import SwiftUI

/// The nearby devices, strongest signal first; or why Bluetooth cannot scan.
///
/// As in Find Air: settings at the top left, help at the top right, the list, a scan button.
/// The scan never stops while the app is open; Cerca di nuovo forgets the list and listens
/// from scratch.
struct MainView: View {
    @Environment(\.showSettings) private var showSettings
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    let model: ScanModel

    @State private var isShowingHelp = false

    private var isSearching: Bool {
        // Behind the card while it is up: it already says the search is running.
        model.state == .ready && model.devices.isEmpty && model.hiddenUnnamedCount == 0 && !model.scanCard.isVisible
    }

    var body: some View {
        List {
            // One card per device, as in Find Air.
            ForEach(model.devices) { device in
                Section {
                    NavigationLink(value: device.id) {
                        DeviceRow(device: device)
                    }
                    .listRowBackground(SbuTheme.surfaceRaised)
                }
            }

            if model.hiddenUnnamedCount > 0 {
                Section {
                } footer: {
                    Text("Dispositivi senza nome nascosti: \(model.hiddenUnnamedCount). Puoi mostrarli in Impostazioni.")
                        .font(SbuTheme.footnote)
                        .foregroundStyle(SbuTheme.inkMuted)
                }
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
            FinderView(model: model, deviceID: id)
        }
        .overlay {
            if let notice = BluetoothNotice(state: model.state) {
                BluetoothNoticeView(notice: notice)
            } else if isSearching {
                NoticeView(
                    title: "Ricerca in corso",
                    message: "Tieni il dispositivo acceso e fuori dalla custodia: Sbu Find sente solo quello che trasmette.",
                    systemImage: "antenna.radiowaves.left.and.right",
                    isWaiting: true
                ) {
                    EmptyView()
                }
            }
        }
        .safeAreaInset(edge: .bottom) {
            if model.state == .ready {
                ScanBottom(model: model)
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

#Preview("Ricerca in corso") {
    MainViewPreview(scanner: FixedScanner(devices: []))
}

private struct MainViewPreview: View {
    @State private var model: ScanModel

    init(scanner: FixedScanner) {
        _model = State(initialValue: ScanModel(scanner: scanner))
    }

    var body: some View {
        NavigationStack {
            MainView(model: model)
                .task { await model.run() }
        }
    }
}
