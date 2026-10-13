// iOS only: the shell, the settings and list rows have no place on Apple Watch.
#if os(iOS)

import SwiftUI

/// The standard frame of a Sbu app: a NavigationStack with the app's tool screen on `surface`,
/// and a settings sheet that always ends with the sbu.dev promise and footer.
///
/// Every screen, the tool screen included, sits on paper and follows the system color scheme.
/// The app's accent is the tint: the full stop, filled buttons and controls. Each app has one
/// thing to do, so there is no tab bar: settings open from the gear in the toolbar, or, with
/// `settingsButtonPlacement: .content`, from a button the tool screen draws itself and wires to
/// the `showSettings` environment action. The action is in the content's environment either way.
public struct SbuAppShell<Content: View, Settings: View>: View {
    private static var settingsTitle: String { String(localized: "Impostazioni", bundle: SbuTheme.bundle) }

    private let title: LocalizedStringKey
    private let slug: String
    private let accent: Color
    private let appIcon: Image
    private let settingsButtonPlacement: SbuSettingsButtonPlacement
    private let dataLocation: SbuDataLocation
    private let content: Content
    private let settings: Settings

    @State private var isShowingSettings = false

    /// Creates the shell.
    /// - Parameters:
    ///   - title: App name, shown as the inline navigation title.
    ///   - slug: The app's sbu.dev slug, such as `habits`: settings link to its privacy page.
    ///   - accent: The app's `accent*` token. Text on it is always `onAccent`.
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
        accent: Color,
        appIcon: Image,
        settingsButtonPlacement: SbuSettingsButtonPlacement = .toolbar,
        dataLocation: SbuDataLocation = .thisDevice,
        @ViewBuilder content: () -> Content,
        @ViewBuilder settings: () -> Settings
    ) {
        self.title = title
        self.slug = slug
        self.accent = accent
        self.appIcon = appIcon
        self.settingsButtonPlacement = settingsButtonPlacement
        self.dataLocation = dataLocation
        self.content = content()
        self.settings = settings()
    }

    public var body: some View {
        NavigationStack {
            content
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                .background(SbuTheme.surface)
                .navigationTitle(title)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    if settingsButtonPlacement == .toolbar {
                        ToolbarItem(placement: .topBarTrailing) {
                            // In ink: on the tool screen the accent belongs to the figure's full stop.
                            Button(Self.settingsTitle, systemImage: "gearshape", action: showSettings)
                                .tint(SbuTheme.ink)
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
        .tint(accent)
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
    SbuAppShell("Sbu Habits", slug: "habits", accent: SbuTheme.accentHabits, appIcon: Image(decorative: "sbu-mark", bundle: SbuTheme.bundle), settingsButtonPlacement: .content) {
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
            .tint(SbuTheme.ink)
        }
        .padding(SbuTheme.space4)
    }
}

private struct SbuAppShellPreview: View {
    var body: some View {
        SbuAppShell("Sbu Subscriptions", slug: "subscriptions", accent: SbuTheme.accentSubscriptions, appIcon: Image(decorative: "sbu-mark", bundle: SbuTheme.bundle)) {
            VStack(spacing: SbuTheme.space6) {
                SbuStat("Spesa mensile", value: Decimal(string: "128.90") ?? 0, format: .currency(code: "EUR"))
                Spacer()
                SbuButton("Aggiungi abbonamento") {}
            }
            .padding(SbuTheme.space4)
        } settings: {
            Section("Promemoria") {
                Text(verbatim: "Un giorno prima")
            }
        }
    }
}

#endif
