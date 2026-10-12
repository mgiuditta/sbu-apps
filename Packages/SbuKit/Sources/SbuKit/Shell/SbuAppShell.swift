import SwiftUI

/// The standard frame of a Sbu app: a NavigationStack with the app's one screen, and a settings
/// sheet that always ends with the sbu.dev promise and footer.
///
/// The shell sets the app accent as tint. Each app has one thing to do, so there is no tab bar:
/// settings open from the toolbar.
public struct SbuAppShell<Content: View, Settings: View>: View {
    private static var settingsTitle: String { String(localized: "Impostazioni", bundle: SbuTheme.bundle) }

    private let title: LocalizedStringKey
    private let accent: Color
    private let onAccent: Color
    private let appIcon: Image
    private let content: Content
    private let settings: Settings

    @State private var isShowingSettings = false

    /// Creates the shell.
    /// - Parameters:
    ///   - title: App name, shown as the large navigation title.
    ///   - accent: The app's `accent*` token.
    ///   - onAccent: Text color on the accent: `onAccent`, or `onAccentLevel` for Sbu Level.
    ///   - appIcon: The icon artwork shown at the top of settings.
    ///   - content: The app's main screen.
    ///   - settings: App-specific settings sections, placed above the sbu.dev footer.
    public init(
        _ title: LocalizedStringKey,
        accent: Color,
        onAccent: Color = SbuTheme.onAccent,
        appIcon: Image,
        @ViewBuilder content: () -> Content,
        @ViewBuilder settings: () -> Settings
    ) {
        self.title = title
        self.accent = accent
        self.onAccent = onAccent
        self.appIcon = appIcon
        self.content = content()
        self.settings = settings()
    }

    public var body: some View {
        NavigationStack {
            content
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                .background(SbuTheme.surface)
                .navigationTitle(title)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button(Self.settingsTitle, systemImage: "gearshape", action: showSettings)
                    }
                }
                .sheet(isPresented: $isShowingSettings) {
                    SbuSettingsView(appName: title, appIcon: appIcon) {
                        settings
                    }
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
        SbuAppShell("Sbu Subscriptions", accent: SbuTheme.accentSubscriptions, appIcon: Image(decorative: "sbu-mark", bundle: SbuTheme.bundle)) {
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
