import SbuKit
import SwiftUI

/// Se hai perso un solo auricolare: the steps numbered, then Find My for Apple products.
struct AirPodGuideView: View {
    var body: some View {
        List {
            Section {
                ForEach(Array(AirPodGuide.steps.enumerated()), id: \.element.id) { index, step in
                    GuideStepRow(number: index + 1, step: step)
                }
            }
            .listRowBackground(SbuTheme.surfaceRaised)

            Section {
                Label {
                    Text("Sbu Find non fa suonare gli auricolari: se sono collegati all'iPhone, Fai suonare nel dettaglio li fa suonare in cuffia.")
                        .font(SbuTheme.body)
                        .foregroundStyle(SbuTheme.ink)
                } icon: {
                    Image(systemName: "speaker.wave.2")
                        .fontWeight(.medium)
                        .imageScale(.medium)
                        .foregroundStyle(SbuTheme.inkMuted)
                }
            }
            .listRowBackground(SbuTheme.surfaceRaised)

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
        .navigationTitle("Un auricolare solo")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview("Light") {
    NavigationStack {
        AirPodGuideView()
    }
    .tint(SbuTheme.accentFind)
}

#Preview("Dark") {
    NavigationStack {
        AirPodGuideView()
    }
    .tint(SbuTheme.accentFind)
    .preferredColorScheme(.dark)
}
