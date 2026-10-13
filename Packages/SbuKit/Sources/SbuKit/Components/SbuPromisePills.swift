import SwiftUI

/// The four promise pills of `SbuFreeBadge`. The wording is fixed: same sentences as the App Store listing.
/// Only the data pill follows `dataLocation`, so an app syncing through the user's iCloud stays truthful.
struct SbuPromisePills: View {
    var dataLocation: SbuDataLocation = .thisDevice

    /// The four promises, in order; the last one says where the data stays.
    static func promises(dataLocation: SbuDataLocation) -> [LocalizedStringResource] {
        let data: LocalizedStringResource = switch dataLocation {
        case .thisDevice: LocalizedStringResource("Dati solo su questo iPhone", bundle: .atURL(SbuTheme.bundle.bundleURL))
        case .yourDevices: LocalizedStringResource("Dati solo sui tuoi dispositivi", bundle: .atURL(SbuTheme.bundle.bundleURL))
        }
        return [
            LocalizedStringResource("Nessun account", bundle: .atURL(SbuTheme.bundle.bundleURL)),
            LocalizedStringResource("Nessuna pubblicità", bundle: .atURL(SbuTheme.bundle.bundleURL)),
            LocalizedStringResource("Nessun acquisto in-app", bundle: .atURL(SbuTheme.bundle.bundleURL)),
            data,
        ]
    }

    var body: some View {
        SbuFlowLayout(spacing: SbuTheme.space2) {
            ForEach(Self.promises(dataLocation: dataLocation), id: \.key) { promise in
                HStack(spacing: SbuTheme.space1) {
                    Circle()
                        .fill(SbuTheme.success)
                        .frame(width: SbuTheme.space2, height: SbuTheme.space2)
                        .accessibilityHidden(true)

                    Text(promise)
                        .font(SbuTheme.footnote.weight(.medium))
                        .foregroundStyle(SbuTheme.ink)
                }
                .padding(.horizontal, SbuTheme.space3)
                .padding(.vertical, SbuTheme.space1)
                .background(SbuTheme.surfaceRaised, in: .rect(cornerRadius: SbuTheme.radiusPill))
            }
        }
    }
}
