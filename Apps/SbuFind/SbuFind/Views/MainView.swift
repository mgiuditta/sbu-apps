import SbuKit
import SwiftUI

/// The nearby devices, strongest signal first; or why Bluetooth cannot scan.
struct MainView: View {
    let model: ScanModel

    var body: some View {
        List(model.devices) { device in
            Label {
                if let name = device.name {
                    Text(verbatim: name)
                } else {
                    Text("Senza nome")
                }
            } icon: {
                Image(systemName: device.kind.systemImage)
            }
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
        .overlay {
            if let notice = BluetoothNotice(state: model.state) {
                BluetoothNoticeView(notice: notice)
            }
        }
    }
}

#Preview("Light") {
    MainView(model: ScanModel(scanner: FixedScanner()))
}

#Preview("Dark") {
    MainView(model: ScanModel(scanner: FixedScanner(state: .denied)))
        .preferredColorScheme(.dark)
}
