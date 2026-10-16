import SbuKit
import SwiftUI

/// The hot and cold search for one device: how near it sounds as one figure, the word under it,
/// a bar in the accent, and how to move.
///
/// As in Find Air: the device's name as the title, a hint to move, the figure growing as you get
/// closer. No ring and no product picture.
struct FinderView: View {
    let model: ScanModel
    let deviceID: UUID

    var body: some View {
        FinderContent(tracked: model.tracked)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .background(SbuTheme.surface)
            .navigationTitle(Text(verbatim: model.tracked?.device.name ?? ""))
            .navigationBarTitleDisplayMode(.inline)
            .overlay {
                if let notice = BluetoothNotice(state: model.state) {
                    BluetoothNoticeView(notice: notice)
                }
            }
            .onAppear(perform: startTracking)
            .onDisappear(perform: model.stopTracking)
    }

    private func startTracking() {
        model.track(deviceID)
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
    @State private var model = ScanModel(scanner: FixedScanner())

    var body: some View {
        NavigationStack {
            FinderView(model: model, deviceID: FixedScanner.demoDevices[0].id)
                .task { await model.run() }
        }
    }
}
