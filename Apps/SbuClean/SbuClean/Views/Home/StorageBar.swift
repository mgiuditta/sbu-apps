import SbuKit
import SwiftUI

/// The iPhone's storage as a bar, as Settings shows it: used out of total.
struct StorageBar: View {
    let storage: DeviceStorage

    var body: some View {
        VStack(alignment: .leading, spacing: SbuTheme.space1) {
            HStack(alignment: .firstTextBaseline) {
                Text("iPhone")
                    .foregroundStyle(SbuTheme.ink)
                Spacer(minLength: SbuTheme.space2)
                Text("\(storage.usedBytes.formatted(.byteCount(style: .file))) usati su \(storage.totalBytes.formatted(.byteCount(style: .file)))")
                    .foregroundStyle(SbuTheme.inkMuted)
                    .multilineTextAlignment(.trailing)
            }
            .font(SbuTheme.footnote)

            ProgressView(value: storage.usedFraction)
                .accessibilityHidden(true)
        }
        .accessibilityElement(children: .combine)
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
