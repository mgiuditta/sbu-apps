// iOS only: the shell, the settings and list rows have no place on Apple Watch.
#if os(iOS)

import SwiftUI

/// The standard frame of a Sbu app: a NavigationStack with the app's tool screen on `paper`,
/// and a settings sheet that always ends with the sbu.dev promise and footer.
///
/// Every screen sits on paper and follows the system color scheme. The tint is `ink`: controls,
/// filled buttons and links. The app's accent reaches only the `.set` full stop and the Closure,
/// through `\.sbuAccent`. Every `Toggle` takes `SbuToggleStyle`. The tool screen draws its own title
/// with `SbuScreenTitle`, so the bar shows no title there; it stays for the back button. Each app has one
/// thing to do, so there is no tab bar: settings open from the gear in the toolbar, or, with
/// `settingsButtonPlacement: .content`, from a button the tool screen draws itself and wires to
/// the `showSettings` environment action. The action is in the content's environment either way.
public struct SbuAppShell<Content: View, Settings: View>: View {
    private static var settingsTitle: String { String(localized: "Impostazioni", bundle: SbuTheme.bundle) }

    private let title: LocalizedStringKey
    private let slug: String
    private let accent: SbuAccent
    private let appIcon: Image
    private let settingsButtonPlacement: SbuSettingsButtonPlacement
    private let dataLocation: SbuDataLocation
    private let content: Content
    private let settings: Settings

    @State private var isShowingSettings = false
    @State private var pulse = SbuFigurePulse()

    /// Creates the shell.
    /// - Parameters:
    ///   - title: App name, at the top of settings and as the back button of pushed screens.
    ///   - slug: The app's sbu.dev slug, such as `habits`: settings link to its privacy page.
    ///   - accent: The app's accent, `SbuAccent.<app>`.
    ///   - appIcon: The icon artwork shown at the top of settings.
    ///   - settingsButtonPlacement: Where the gear that opens settings goes; `.toolbar` unless
    ///     the tool screen draws its own and calls `showSettings`.
    ///   - dataLocation: Where the promise pills in settings say the data stays; `.yourDevices`
    ///     only while the app syncs through the user's iCloud.
    ///   - content: The app's tool screen.
    ///   - settings: App-specific settings sections, placed above the sbu.dev footer.
    public init(
        _ title: LocalizedStringKey,
        slug: String,
        accent: SbuAccent,
        appIcon: Image,
        settingsButtonPlacement: SbuSettingsButtonPlacement = .toolbar,
        dataLocation: SbuDataLocation = .thisDevice,
        @ViewBuilder content: () -> Content,
        @ViewBuilder settings: () -> Settings
    ) {
        _ = SbuNavigationBarAppearance.apply
        self.title = title
        self.slug = slug
        self.accent = accent
        self.appIcon = appIcon
        self.settingsButtonPlacement = settingsButtonPlacement
        self.dataLocation = dataLocation
        self.content = content()
        self.settings = settings()
    }

    /// Creates the shell from a v4 accent color: the Closure's full stop takes the same color.
    @available(*, deprecated, message: "Pass SbuAccent.<app>.")
    public init(
        _ title: LocalizedStringKey,
        slug: String,
        accent: Color,
        appIcon: Image,
        settingsButtonPlacement: SbuSettingsButtonPlacement = .toolbar,
        dataLocation: SbuDataLocation = .thisDevice,
        @ViewBuilder content: () -> Content,
        @ViewBuilder settings: () -> Settings
    ) {
        self.init(title, slug: slug, accent: SbuAccent(base: accent, onInk: accent), appIcon: appIcon,
                  settingsButtonPlacement: settingsButtonPlacement, dataLocation: dataLocation,
                  content: content, settings: settings)
    }

    public var body: some View {
        NavigationStack {
            content
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                .background(SbuTheme.paper)
                .navigationTitle(title)
                .navigationBarTitleDisplayMode(.inline)
                .sbuFullStopAudit(slug)
                .toolbar {
                    // The tool screen's title is SbuScreenTitle: the bar stays empty.
                    ToolbarItem(placement: .principal) {
                        Text(verbatim: "")
                            .accessibilityHidden(true)
                    }
                    if settingsButtonPlacement == .toolbar {
                        ToolbarItem(placement: .topBarTrailing) {
                            Button(Self.settingsTitle, systemImage: "gearshape", action: showSettings)
                        }
                    }
                }
                .environment(\.showSettings, SbuShowSettingsAction(showSettings))
        }
        .sheet(isPresented: $isShowingSettings) {
            SbuSettingsView(appName: title, appIcon: appIcon, slug: slug, dataLocation: dataLocation) {
                settings
            }
        }
        .toggleStyle(SbuToggleStyle())
        .environment(\.sbuAccent, accent)
        .environment(\.sbuFigurePulse, pulse)
        .tint(SbuTheme.ink)
    }

    private func showSettings() {
        isShowingSettings = true
    }
}

#Preview("Light") {
    SbuAppShellPreview()
}

#Preview("Dark") {
    SbuAppShellPreview()
        .preferredColorScheme(.dark)
}

#Preview("Ingranaggio nel contenuto") {
    SbuAppShell("Sbu Habits", slug: "habits", accent: .habits, appIcon: Image(decorative: "sbu-mark", bundle: SbuTheme.bundle), settingsButtonPlacement: .content) {
        SbuAppShellContentGearPreview()
    } settings: {
        EmptyView()
    }
}

private struct SbuAppShellContentGearPreview: View {
    @Environment(\.showSettings) private var showSettings

    var body: some View {
        VStack {
            Spacer()
            Button(String(localized: "Impostazioni", bundle: SbuTheme.bundle), systemImage: "gearshape") {
                showSettings()
            }
        }
        .padding(SbuTheme.space4)
    }
}

private struct SbuAppShellPreview: View {
    var body: some View {
        SbuAppShell("Sbu Subscriptions", slug: "subscriptions", accent: .subscriptions, appIcon: Image(decorative: "sbu-mark", bundle: SbuTheme.bundle)) {
            VStack(alignment: .leading, spacing: SbuTheme.space6) {
                SbuScreenTitle("Abbonamenti", cartiglio: "Sbu · Abbonamenti · ottobre 2026")
                SbuFigure(value: (Decimal(string: "47.90") ?? 0).formatted(.currency(code: "EUR")), context: Text(verbatim: "al mese"))
                Toggle("Avvisa il giorno prima", isOn: .constant(true))
                Spacer()
                SbuButton("Aggiungi abbonamento") {}
            }
            .padding(.horizontal, SbuTheme.space4)
            .sbuPaper()
        } settings: {
            Section("Promemoria") {
                Text(verbatim: "Un giorno prima")
            }
        }
    }
}

#endif
