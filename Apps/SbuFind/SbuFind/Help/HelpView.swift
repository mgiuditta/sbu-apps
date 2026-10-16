import SbuKit
import SwiftUI

/// The help page: how to search, what Sbu Find cannot hear, and when Apple's Find My does better.
///
/// The limits are said plainly here and in the App Store listing: the reviews of Find Air punish
/// screenshots that promise more than a Bluetooth scan can do.
struct HelpView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                ForEach(HelpSection.all) { section in
                    Section {
                        ForEach(section.items) { item in
                            Label {
                                Text(item.text)
                                    .font(SbuTheme.body)
                                    .foregroundStyle(SbuTheme.ink)
                            } icon: {
                                Image(systemName: item.systemImage)
                                    .fontWeight(.medium)
                                    .imageScale(.medium)
                                    .foregroundStyle(SbuTheme.inkMuted)
                            }
                        }

                        if section.id == HelpSection.singleAirPodID {
                            NavigationLink {
                                AirPodGuideView()
                            } label: {
                                Text("Guida passo per passo")
                                    .font(SbuTheme.body)
                                    .foregroundStyle(SbuTheme.ink)
                            }
                        }
                    } header: {
                        Text(section.title)
                    }
                    .listRowBackground(SbuTheme.surfaceRaised)
                }

                if let url = HelpSection.findMyURL {
                    Section {
                        Link(destination: url) {
                            HStack {
                                Text("Apri Dov'è")
                                    .font(SbuTheme.body)

                                Spacer(minLength: 0)

                                Image(systemName: "arrow.up.right")
                                    .fontWeight(.medium)
                                    .imageScale(.medium)
                                    .foregroundStyle(SbuTheme.inkMuted)
                                    .accessibilityHidden(true)
                            }
                        }
                        .accessibilityHint(Text("Apre l'app Dov'è di Apple"))
                    }
                    .listRowBackground(SbuTheme.surfaceRaised)
                }
            }
            .listStyle(.insetGrouped)
            .scrollContentBackground(.hidden)
            .background(SbuTheme.surface)
            .navigationTitle("Aiuto")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Fine", action: close)
                }
            }
        }
    }

    private func close() {
        dismiss()
    }
}

#Preview("Light") {
    HelpView()
        .tint(SbuTheme.accentFind)
}

#Preview("Dark") {
    HelpView()
        .tint(SbuTheme.accentFind)
        .preferredColorScheme(.dark)
}
