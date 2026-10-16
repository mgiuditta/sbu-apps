import SbuKit
import SwiftUI

/// The bottom of the list: the "Ricerca…" card while a scan starts, Cerca di nuovo after it.
/// The card slides up from the bottom, or fades with Reduce Motion.
struct ScanBottom: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    let model: ScanModel

    var body: some View {
        ZStack {
            if model.scanCard.isVisible {
                ScanCardView(close: close)
                    .padding(.bottom, SbuTheme.space2)
                    .transition(reduceMotion ? .opacity : .move(edge: .bottom).combined(with: .opacity))
            } else {
                SbuButton("Cerca di nuovo", action: rescan)
                    .padding(.horizontal, SbuTheme.space4)
                    .padding(.vertical, SbuTheme.space2)
                    .transition(.opacity)
            }
        }
        .frame(maxWidth: .infinity)
        .background(SbuTheme.surface)
        .animation(reduceMotion ? .default : .spring(duration: 0.45), value: model.scanCard.isVisible)
    }

    private func close() {
        model.closeScanCard()
    }

    private func rescan() {
        model.rescan()
    }
}

#Preview("Light") {
    VStack {
        Spacer()
        ScanBottom(model: ScanModel(scanner: FixedScanner()))
    }
    .tint(SbuTheme.accentFind)
}

#Preview("Dark") {
    VStack {
        Spacer()
        ScanBottom(model: ScanModel(scanner: FixedScanner()))
    }
    .tint(SbuTheme.accentFind)
    .preferredColorScheme(.dark)
}
