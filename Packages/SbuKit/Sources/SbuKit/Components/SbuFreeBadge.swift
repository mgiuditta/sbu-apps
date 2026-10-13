import SwiftUI

/// The sbu.dev promise: the opposite of a paywall. Its content is fixed and identical in every app.
///
/// `.pills` goes in onboarding and the second App Store screenshot; `.footer` goes at the bottom
/// of every app's settings and links to sbu.dev.
public struct SbuFreeBadge: View {
    private let style: Style
    private let dataLocation: SbuDataLocation

    /// Creates the badge.
    /// - Parameters:
    ///   - style: The four promise pills, or the "Parte di sbu.dev" footer.
    ///   - dataLocation: Where the data pill says the data stays; `.thisDevice` unless the app
    ///     syncs through the user's iCloud and sync is on.
    public init(style: Style, dataLocation: SbuDataLocation = .thisDevice) {
        self.style = style
        self.dataLocation = dataLocation
    }

    public var body: some View {
        switch style {
        case .pills: SbuPromisePills(dataLocation: dataLocation)
        case .footer: SbuFooterLink()
        }
    }
}

public extension SbuFreeBadge {
    /// How `SbuFreeBadge` is drawn.
    enum Style: Sendable {
        /// Four pills with a `success` dot.
        case pills
        /// The sbu.dev mark with "Parte di sbu.dev", linking to sbu.dev.
        case footer
    }
}

#Preview("Light") {
    SbuFreeBadgePreview()
}

#Preview("Dark") {
    SbuFreeBadgePreview()
        .preferredColorScheme(.dark)
}

private struct SbuFreeBadgePreview: View {
    var body: some View {
        VStack(alignment: .leading, spacing: SbuTheme.space4) {
            SbuFreeBadge(style: .pills)
            SbuFreeBadge(style: .pills, dataLocation: .yourDevices)
            SbuFreeBadge(style: .footer)
        }
        .padding(SbuTheme.space4)
        .frame(maxHeight: .infinity)
        .background(SbuTheme.surface)
    }
}
