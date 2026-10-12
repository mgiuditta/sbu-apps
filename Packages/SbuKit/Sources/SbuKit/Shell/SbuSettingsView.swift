import SwiftUI

/// The settings sheet of `SbuAppShell`: app header, app sections, then the sbu.dev promise.
struct SbuSettingsView<Settings: View>: View {
    @Environment(\.dismiss) private var dismiss

    let appName: LocalizedStringKey
    let appIcon: Image
    @ViewBuilder let settings: Settings

    private var version: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? ""
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
        .presentationCornerRadius(SbuTheme.radiusXl)
    }

    private func close() {
        dismiss()
    }
}
