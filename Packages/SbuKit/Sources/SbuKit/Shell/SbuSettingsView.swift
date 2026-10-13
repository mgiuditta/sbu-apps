// iOS only: the shell, the settings and list rows have no place on Apple Watch.
#if os(iOS)

import SwiftUI

/// The settings sheet of `SbuAppShell`: app header, app sections, the privacy page, then the sbu.dev promise.
struct SbuSettingsView<Settings: View>: View {
    @Environment(\.dismiss) private var dismiss

    let appName: LocalizedStringKey
    let appIcon: Image
    let slug: String
    @ViewBuilder let settings: Settings

    private var version: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? ""
    }

    /// The privacy page in the language these settings are shown in.
    private var privacyURL: URL {
        SbuPrivacyPage.url(slug: slug, languageCode: SbuTheme.bundle.preferredLocalizations.first)
    }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    HStack(spacing: SbuTheme.space4) {
                        SbuAppIconView(image: appIcon)

                        VStack(alignment: .leading, spacing: 0) {
                            Text(appName)
                                .font(SbuTheme.headline)
                                .foregroundStyle(SbuTheme.ink)

                            Text("Versione \(version)", bundle: SbuTheme.bundle)
                                .font(SbuTheme.footnote)
                                .foregroundStyle(SbuTheme.inkMuted)
                        }
                    }
                    .accessibilityElement(children: .combine)
                }
                .listRowBackground(SbuTheme.surfaceRaised)

                settings
                    .listRowBackground(SbuTheme.surfaceRaised)

                Section {
                    Link(destination: privacyURL) {
                        HStack {
                            Text("Privacy", bundle: SbuTheme.bundle)
                                .font(SbuTheme.body)
                                .foregroundStyle(SbuTheme.ink)

                            Spacer(minLength: 0)

                            Image(systemName: "arrow.up.right")
                                .fontWeight(.medium)
                                .imageScale(.medium)
                                .foregroundStyle(SbuTheme.inkMuted)
                                .accessibilityHidden(true)
                        }
                    }
                    .accessibilityHint(Text("Apre sbu.dev in Safari", bundle: SbuTheme.bundle))

                    NavigationLink {
                        SbuLicensesView()
                    } label: {
                        Text("Licenze", bundle: SbuTheme.bundle)
                            .font(SbuTheme.body)
                            .foregroundStyle(SbuTheme.ink)
                    }
                }
                .listRowBackground(SbuTheme.surfaceRaised)

                Section {
                    SbuFreeBadge(style: .pills)
                        .listRowBackground(Color.clear)
                        .listRowInsets(EdgeInsets())

                    SbuFreeBadge(style: .footer)
                        .listRowBackground(Color.clear)
                        .listRowInsets(EdgeInsets())
                        .padding(.top, SbuTheme.space3)
                }
                .listRowSeparator(.hidden)
            }
            .listStyle(.insetGrouped)
            .listSectionSpacing(SbuTheme.space6)
            .scrollContentBackground(.hidden)
            .background(SbuTheme.surface)
            .navigationTitle(Text("Impostazioni", bundle: SbuTheme.bundle))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(String(localized: "Fine", bundle: SbuTheme.bundle), action: close)
                }
            }
        }
        .presentationCornerRadius(cornerRadius)
    }

    /// `radiusXl` up to iOS 18; from iOS 26 the system radius that matches Liquid Glass.
    private var cornerRadius: CGFloat? {
        if #available(iOS 26, *) { nil } else { SbuTheme.radiusXl }
    }

    private func close() {
        dismiss()
    }
}

#Preview("Light") {
    SbuSettingsPreview()
}

#Preview("Dark") {
    SbuSettingsPreview()
        .preferredColorScheme(.dark)
}

private struct SbuSettingsPreview: View {
    var body: some View {
        SbuSettingsView(appName: "Sbu Habits", appIcon: Image(decorative: "sbu-mark", bundle: SbuTheme.bundle), slug: "habits") {
            Section("Promemoria") {
                Text(verbatim: "Alle 9:00")
            }
        }
    }
}

#endif
