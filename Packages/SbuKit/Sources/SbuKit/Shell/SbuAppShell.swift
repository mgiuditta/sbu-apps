import SwiftUI

/// The standard frame of a Sbu app: a NavigationStack with the app's tool screen on its dark
/// field, and a settings sheet that always ends with the sbu.dev promise and footer.
///
/// The tool screen is always dark: the shell paints the app's `field*` edge to edge and runs it
/// in the dark color scheme, so the accent tint takes its dark value. The settings sheet stays in
/// the system color scheme. Each app has one thing to do, so there is no tab bar: settings open
/// from the gear in the toolbar.
public struct SbuAppShell<Content: View, Settings: View>: View {
    private static var settingsTitle: String { String(localized: "Impostazioni", bundle: SbuTheme.bundle) }

    private let title: LocalizedStringKey
    private let slug: String
    private let accent: Color
    private let onAccent: Color
    private let field: Color
    private let appIcon: Image
    private let content: Content
    private let settings: Settings

    @State private var isShowingSettings = false

    /// Creates the shell.
    /// - Parameters:
    ///   - title: App name, shown as the inline navigation title.
    ///   - slug: The app's sbu.dev slug, such as `habits`: settings link to its privacy page.
    ///   - accent: The app's `accent*` token.
    ///   - onAccent: Text color on the accent: `onAccent`, or `onAccentLevel` for Sbu Level.
    ///   - field: The app's `field*` token, the background of the tool screen.
    ///   - appIcon: The icon artwork shown at the top of settings.
    ///   - content: The app's tool screen.
    ///   - settings: App-specific settings sections, placed above the sbu.dev footer.
    public init(
        _ title: LocalizedStringKey,
        slug: String,
        accent: Color,
        onAccent: Color = SbuTheme.onAccent,
        field: Color,
        appIcon: Image,
        @ViewBuilder content: () -> Content,
        @ViewBuilder settings: () -> Settings
    ) {
        self.title = title
        self.slug = slug
        self.accent = accent
        self.onAccent = onAccent
        self.field = field
        self.appIcon = appIcon
        self.content = content()
        self.settings = settings()
    }

    public var body: some View {
        NavigationStack {
            content
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                .background(field)
                .navigationTitle(title)
                .navigationBarTitleDisplayMode(.inline)
                .toolbarColorScheme(.dark, for: .navigationBar)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button(Self.settingsTitle, systemImage: "gearshape", action: showSettings)
                            .tint(SbuTheme.onField)
                    }
                }
        }
        .environment(\.colorScheme, .dark)
        // Attached outside the dark environment, so settings follow the system color scheme.
        .sheet(isPresented: $isShowingSettings) {
            SbuSettingsView(appName: title, appIcon: appIcon, slug: slug) {
                settings
            }
        }
        .tint(accent)
        .environment(\.sbuOnAccent, onAccent)
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

private struct SbuAppShellPreview: View {
    var body: some View {
        SbuAppShell("Sbu Subscriptions", slug: "subscriptions", accent: SbuTheme.accentSubscriptions, field: SbuTheme.fieldSubscriptions, appIcon: Image(decorative: "sbu-mark", bundle: SbuTheme.bundle)) {
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
