import ManagedSettings
import ManagedSettingsUI
import SbuKit
import SwiftUI
import UIKit

/// The Sbu Shield over a native app: paper, ink, and the way to the same social without short videos.
final class ShieldConfigurationExtension: ShieldConfigurationDataSource {
    override func configuration(shielding application: Application) -> ShieldConfiguration {
        configuration(named: application.localizedDisplayName)
    }

    override func configuration(shielding application: Application, in category: ActivityCategory) -> ShieldConfiguration {
        configuration(named: application.localizedDisplayName)
    }

    private func configuration(named name: String?) -> ShieldConfiguration {
        let title = name.map { String(localized: "\($0) è schermata") } ?? String(localized: "App schermata")
        return ShieldConfiguration(
            backgroundBlurStyle: nil,
            backgroundColor: UIColor(SbuTheme.paper),
            icon: UIImage(systemName: "shield"),
            title: .init(text: title, color: UIColor(SbuTheme.ink)),
            subtitle: .init(text: String(localized: "Aprila in Sbu Social, senza video brevi."), color: UIColor(SbuTheme.inkMuted)),
            primaryButtonLabel: .init(text: String(localized: "Apri in Sbu Social"), color: UIColor(SbuTheme.paper)),
            primaryButtonBackgroundColor: UIColor(SbuTheme.ink),
            secondaryButtonLabel: .init(text: String(localized: "Chiudi"), color: UIColor(SbuTheme.ink))
        )
    }
}
