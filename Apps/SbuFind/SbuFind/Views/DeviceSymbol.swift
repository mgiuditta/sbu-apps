import SbuKit
import SwiftUI

/// The symbol of a device's kind at the start of its row, in `inkMuted`. Hidden from VoiceOver:
/// the row says the kind in words.
struct DeviceSymbol: View {
    let systemImage: String

    var body: some View {
        Image(systemName: systemImage)
            .resizable()
            .scaledToFit()
            .fontWeight(.medium)
            .foregroundStyle(SbuTheme.inkMuted)
            .accessibilityHidden(true)
    }
}

#Preview("Light") {
    HStack(spacing: SbuTheme.space4) {
        DeviceSymbol(systemImage: "airpods")
        DeviceSymbol(systemImage: "applewatch")
        DeviceSymbol(systemImage: "headphones")
    }
    .frame(height: SbuTheme.controlRoundXs)
    .padding(SbuTheme.space4)
    .sbuPaper(grid: false)
}

#Preview("Dark") {
    HStack(spacing: SbuTheme.space4) {
        DeviceSymbol(systemImage: "airpods")
        DeviceSymbol(systemImage: "applewatch")
        DeviceSymbol(systemImage: "headphones")
    }
    .frame(height: SbuTheme.controlRoundXs)
    .padding(SbuTheme.space4)
    .sbuPaper(grid: false)
    .preferredColorScheme(.dark)
}
