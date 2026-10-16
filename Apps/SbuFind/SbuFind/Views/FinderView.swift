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

    @State private var ticker = ProximityTicker()

    var body: some View {
        // At least as tall as the screen, so the pills sit at the bottom; scrolling only at the
        // largest text sizes, where the figure, the hint and the pills no longer fit.
        GeometryReader { proxy in
            ScrollView {
                FinderContent(tracked: model.tracked) {
                    // In one row, wrapping onto two at the largest text sizes, so no word is cut.
                    PillsLayout(spacing: SbuTheme.space2) {
                        FeedbackPills(model: model)
                    }
                }
                .frame(minHeight: proxy.size.height, alignment: .top)
            }
            .scrollBounceBehavior(.basedOnSize)
        }
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
        .task {
            await tickUntilCancelled()
        }
    }

    private func startTracking() {
        model.track(deviceID)
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
    @State private var model = ScanModel(scanner: FixedScanner())

    var body: some View {
        NavigationStack {
            FinderView(model: model, deviceID: FixedScanner.demoDevices[0].id)
                .task { await model.run() }
        }
    }
}
