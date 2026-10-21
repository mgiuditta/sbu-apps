import SwiftUI

/// Impostazioni: one Platform's filters, each one you can switch off. Reels and Shorts stay
/// blocked: they are the one thing Sbu Social does.
struct FilterSection: View {
    let platform: Platform
    let options: OptionStore
    @Environment(WebViewPool.self) private var pool

    var body: some View {
        Section {
            ForEach(platform.rules.options) { option in
                Toggle(LocalizedStringKey(option.title), isOn: Binding {
                    options.isOn(option, on: platform)
                } set: { isOn in
                    options.set(option, on: platform, to: isOn)
                    pool.reset(platform)
                })
            }
        } header: {
            Text(verbatim: platform.name)
        } footer: {
            Text(platform == .instagram ? "Reels ed Esplora restano sempre bloccati." : "Gli Shorts restano sempre bloccati.")
        }
    }
}

#Preview("Light") {
    Form {
        FilterSection(platform: .instagram, options: OptionStore(defaults: UserDefaults(suiteName: "preview")!))
    }
    .environment(WebViewPool(options: OptionStore(defaults: UserDefaults(suiteName: "preview")!)))
}

#Preview("Dark") {
    Form {
        FilterSection(platform: .youtube, options: OptionStore(defaults: UserDefaults(suiteName: "preview")!))
    }
    .environment(WebViewPool(options: OptionStore(defaults: UserDefaults(suiteName: "preview")!)))
    .preferredColorScheme(.dark)
}
