import SbuKit
import SwiftUI

/// The header of the nearby devices, as in Wunderfind: "Altri dispositivi" and the system
/// spinner while the scan runs.
struct NearbyHeader: View {
    let isScanning: Bool

    var body: some View {
        HStack(spacing: SbuTheme.space2) {
            Text("Altri dispositivi")

            if isScanning {
                ProgressView()
                    .controlSize(.small)
                    .accessibilityHidden(true)
            }
        }
        // One header for VoiceOver: "Altri dispositivi, ricerca in corso".
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text("Altri dispositivi"))
        .accessibilityValue(isScanning ? Text("Ricerca in corso") : Text(verbatim: ""))
        .accessibilityAddTraits(.isHeader)
    }
}

#Preview("Light") {
    List {
        Section {
            Text(verbatim: "Buds Pro")
        } header: {
            NearbyHeader(isScanning: true)
        }
    }
}

#Preview("Dark") {
    List {
        Section {
            Text(verbatim: "Buds Pro")
        } header: {
            NearbyHeader(isScanning: false)
        }
    }
    .preferredColorScheme(.dark)
}
