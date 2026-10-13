import SbuKit
import SwiftUI

/// The iPhone's storage as a bar, as Settings shows it: used out of total.
struct StorageBar: View {
    let storage: DeviceStorage

    var body: some View {
        VStack(alignment: .leading, spacing: SbuTheme.space1) {
            ViewThatFits(in: .horizontal) {
                HStack(alignment: .firstTextBaseline) {
                    name
                    Spacer(minLength: SbuTheme.space2)
                    usage
                }
                VStack(alignment: .leading, spacing: 0) {
                    name
                    usage
                }
            }
            .font(SbuTheme.footnote)

            ProgressView(value: storage.usedFraction)
                .accessibilityHidden(true)
        }
        .accessibilityElement(children: .combine)
    }

    private var name: some View {
        Text("iPhone")
            .foregroundStyle(SbuTheme.ink)
    }

    private var usage: some View {
        Text("\(storage.usedBytes.sizeText) usati su \(storage.totalBytes.sizeText)")
            .foregroundStyle(SbuTheme.inkMuted)
            .fixedSize(horizontal: false, vertical: true)
    }
}

#Preview("Light") {
    StorageBar(storage: DeviceStorage(totalBytes: 128_000_000_000, availableBytes: 21_000_000_000))
        .padding()
        .tint(SbuTheme.accentClean)
}

#Preview("Dark") {
    StorageBar(storage: DeviceStorage(totalBytes: 128_000_000_000, availableBytes: 21_000_000_000))
        .padding()
        .tint(SbuTheme.accentClean)
        .preferredColorScheme(.dark)
}
