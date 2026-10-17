import SbuKit
import SwiftUI

/// The TVs on the Wi-Fi, an address field for the ones that do not show up, and what works.
struct DiscoveryView: View {
    let discovery: TVDiscovery
    let onPick: (TVCandidate) -> Void

    var body: some View {
        List {
            if discovery.isLocalNetworkDenied {
                LocalNetworkDeniedSection()
            }
            FoundTVsSection(tvs: discovery.tvs, isSearching: discovery.isSearching, onPick: onPick)
            ManualAddressSection(onPick: onPick)
            SupportedSystemsSection()
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
        .background(SbuTheme.paper)
        .task {
            discovery.start()
        }
        .onDisappear(perform: discovery.stop)
    }
}

private struct FoundTVsSection: View {
    let tvs: [DiscoveredTV]
    let isSearching: Bool
    let onPick: (TVCandidate) -> Void

    var body: some View {
        Section {
            ForEach(tvs) { tv in
                Button {
                    onPick(TVCandidate(tv))
                } label: {
                    VStack(alignment: .leading, spacing: SbuTheme.space1) {
                        Text(tv.name)
                            .font(SbuTheme.body)
                            .foregroundStyle(SbuTheme.ink)
                        Text(tv.brand.displayName)
                            .font(SbuTheme.subheadline)
                            .foregroundStyle(SbuTheme.inkMuted)
                    }
                }
            }
            if tvs.isEmpty {
                HStack(spacing: SbuTheme.space3) {
                    if isSearching {
                        ProgressView()
                    }
                    Text("Cerco le TV sulla tua Wi-Fi")
                        .font(SbuTheme.body)
                        .foregroundStyle(SbuTheme.inkMuted)
                }
                .accessibilityElement(children: .combine)
            }
        } header: {
            Text("TV trovate")
        } footer: {
            Text("Accendi la TV e collega il telefono alla stessa Wi-Fi.")
        }
        .listRowBackground(SbuTheme.surfaceRaised)
    }
}

private struct ManualAddressSection: View {
    let onPick: (TVCandidate) -> Void

    @State private var address = ""
    @State private var brand = TVBrand.samsung

    private var host: String? { HostInput.normalized(address) }

    var body: some View {
        Section {
            TextField("Indirizzo IP, per esempio 192.168.1.20", text: $address)
                .keyboardType(.numbersAndPunctuation)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .submitLabel(.done)
                .onSubmit(add)
            Picker("Sistema", selection: $brand) {
                ForEach(TVBrand.allCases) { brand in
                    Text(brand.displayName).tag(brand)
                }
            }
            Button("Aggiungi la TV", action: add)
                .disabled(host == nil)
        } header: {
            Text("Per indirizzo")
        } footer: {
            Text("Trovi l'indirizzo IP nelle impostazioni di rete della TV.")
        }
        .listRowBackground(SbuTheme.surfaceRaised)
    }

    private func add() {
        guard let host else { return }
        onPick(TVCandidate(host: host, brand: brand))
    }
}

/// Shown when the user said no to Local Network: without it no TV can be found or reached.
private struct LocalNetworkDeniedSection: View {
    @Environment(\.openURL) private var openURL

    var body: some View {
        Section {
            Label {
                Text("Rete locale disattivata. Attivala in Impostazioni › Privacy e sicurezza › Rete locale › Sbu Remote.")
                    .font(SbuTheme.body)
                    .foregroundStyle(SbuTheme.ink)
            } icon: {
                Image(systemName: "exclamationmark.triangle")
                    .fontWeight(.medium)
                    .foregroundStyle(SbuTheme.warning)
            }
            Button("Apri Impostazioni", action: openSettings)
        }
        .listRowBackground(SbuTheme.surfaceRaised)
    }

    private func openSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        openURL(url)
    }
}

#Preview("Light") {
    NavigationStack {
        DiscoveryView(discovery: TVDiscovery()) { _ in }
            .navigationTitle("Aggiungi una TV")
            .navigationBarTitleDisplayMode(.inline)
    }
    .tint(SbuTheme.ink)
}

#Preview("Dark") {
    NavigationStack {
        DiscoveryView(discovery: TVDiscovery()) { _ in }
            .navigationTitle("Aggiungi una TV")
            .navigationBarTitleDisplayMode(.inline)
    }
    .tint(SbuTheme.ink)
    .preferredColorScheme(.dark)
}
