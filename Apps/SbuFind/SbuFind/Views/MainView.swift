import SbuKit
import SwiftUI

/// The nearby devices, strongest signal first; or why Bluetooth cannot scan.
///
/// As in Find Air: settings at the top left, the list, a scan button. The scan never stops while
/// the app is open; Cerca di nuovo forgets the list and listens from scratch.
struct MainView: View {
    @Environment(\.showSettings) private var showSettings

    let model: ScanModel

    private var isSearching: Bool {
        model.state == .ready && model.devices.isEmpty && model.hiddenUnnamedCount == 0
    }

    var body: some View {
        List {
            Section {
                ForEach(model.devices) { device in
                    NavigationLink(value: device.id) {
                        DeviceRow(device: device)
                    }
                }
            } footer: {
                if model.hiddenUnnamedCount > 0 {
                    Text("Dispositivi senza nome nascosti: \(model.hiddenUnnamedCount). Puoi mostrarli in Impostazioni.")
                        .font(SbuTheme.footnote)
                        .foregroundStyle(SbuTheme.inkMuted)
                }
            }
            .listRowBackground(SbuTheme.surfaceRaised)
            .listRowSeparatorTint(SbuTheme.line)
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
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
                SbuButton("Cerca di nuovo", action: model.rescan)
                    .padding(.horizontal, SbuTheme.space4)
                    .padding(.vertical, SbuTheme.space2)
                    .background(SbuTheme.surface)
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                // In ink: the accent belongs to the finder's full stop.
                Button("Impostazioni", systemImage: "gearshape", action: showSettings.callAsFunction)
                    .tint(SbuTheme.ink)
            }
        }
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
