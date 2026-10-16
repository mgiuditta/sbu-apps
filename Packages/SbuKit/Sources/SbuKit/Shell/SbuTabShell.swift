// iOS only: the shell, the settings and list rows have no place on Apple Watch.
#if os(iOS)

import SwiftUI

/// The frame of a Sbu app with a tab bar, which only an ADR allows (ADR-0012 for Sbu Subscriptions):
/// the app's `SbuTab`s, then Impostazioni as the last tab, ending with the sbu.dev promise and footer
/// as in `SbuAppShell`.
///
/// Every tab sits on paper and follows the system color scheme; the tint is `ink` and the app's
/// accent reaches only the `.set` full stop and the Closure, as in `SbuAppShell`. The
/// `showSettings` environment action selects the Impostazioni tab.
public struct SbuTabShell<Selection: Hashable, Tabs: View, Settings: View>: View {
    private let title: LocalizedStringKey
    private let slug: String
    private let accent: SbuAccent
    private let appIcon: Image
    private let dataLocation: SbuDataLocation
    @Binding private var selection: Selection
    private let settingsTab: Selection
    private let tabs: Tabs
    private let settings: Settings

    @State private var pulse = SbuFigurePulse()

    /// Creates the shell.
    /// - Parameters:
    ///   - title: App name, shown at the top of the Impostazioni tab.
    ///   - slug: The app's sbu.dev slug, such as `subscriptions`: settings link to its privacy page.
    ///   - accent: The app's accent, `SbuAccent.<app>`.
    ///   - appIcon: The icon artwork shown at the top of settings.
    ///   - dataLocation: Where the promise pills in settings say the data stays.
    ///   - selection: The tab on screen.
    ///   - settingsTab: The selection value of the Impostazioni tab, which the shell adds last.
    ///   - tabs: The app's tabs, each an `SbuTab`.
    ///   - settings: App-specific settings sections, placed above the sbu.dev footer.
    public init(
        _ title: LocalizedStringKey,
        slug: String,
        accent: SbuAccent,
        appIcon: Image,
        dataLocation: SbuDataLocation = .thisDevice,
        selection: Binding<Selection>,
        settingsTab: Selection,
        @ViewBuilder tabs: () -> Tabs,
        @ViewBuilder settings: () -> Settings
    ) {
        _ = SbuNavigationBarAppearance.apply
        self.title = title
        self.slug = slug
        self.accent = accent
        self.appIcon = appIcon
        self.dataLocation = dataLocation
        _selection = selection
        self.settingsTab = settingsTab
        self.tabs = tabs()
        self.settings = settings()
    }

    /// Creates the shell from a v4 accent color: the Closure's full stop takes the same color.
    @available(*, deprecated, message: "Pass SbuAccent.<app>.")
    public init(
        _ title: LocalizedStringKey,
        slug: String,
        accent: Color,
        appIcon: Image,
        dataLocation: SbuDataLocation = .thisDevice,
        selection: Binding<Selection>,
        settingsTab: Selection,
        @ViewBuilder tabs: () -> Tabs,
        @ViewBuilder settings: () -> Settings
    ) {
        self.init(title, slug: slug, accent: SbuAccent(base: accent, onInk: accent), appIcon: appIcon,
                  dataLocation: dataLocation, selection: selection, settingsTab: settingsTab,
                  tabs: tabs, settings: settings)
    }

    public var body: some View {
        TabView(selection: $selection) {
            tabs

            SbuSettingsView(appName: title, appIcon: appIcon, slug: slug, dataLocation: dataLocation, isTab: true) {
                settings
            }
            .tabItem {
                Label {
                    Text("Impostazioni", bundle: SbuTheme.bundle)
                } icon: {
                    Image(systemName: "gearshape")
                }
            }
            .tag(settingsTab)
        }
        .environment(\.showSettings, SbuShowSettingsAction(showSettings))
        .toggleStyle(SbuToggleStyle())
        .environment(\.sbuAccent, accent)
        .environment(\.sbuFigurePulse, pulse)
        .tint(SbuTheme.ink)
    }

    private func showSettings() {
        selection = settingsTab
    }
}

#Preview("Light") {
    SbuTabShellPreview()
}

#Preview("Dark") {
    SbuTabShellPreview()
        .preferredColorScheme(.dark)
}

private struct SbuTabShellPreview: View {
    @State private var selection = 0

    var body: some View {
        SbuTabShell("Sbu Subscriptions", slug: "subscriptions", accent: .subscriptions,
                    appIcon: Image(decorative: "sbu-mark", bundle: SbuTheme.bundle), selection: $selection, settingsTab: 2) {
            SbuTab("Abbonamenti", systemImage: "creditcard", value: 0) {
                SbuFigure(value: (Decimal(string: "47.90") ?? 0).formatted(.currency(code: "EUR")))
                    .padding(SbuTheme.space4)
                    .sbuPaper()
            }
            SbuTab("Calendario", systemImage: "calendar", value: 1) {
                Text(verbatim: "Ottobre")
            }
        } settings: {
            Section("Promemoria") {
                Text(verbatim: "Un giorno prima")
            }
        }
    }
}

#endif
