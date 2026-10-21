import SwiftUI

/// Impostazioni: the social opened straight away when the app starts.
struct LaunchSection: View {
    @Bindable var options: OptionStore

    var body: some View {
        Section {
            Picker("Apri all'avvio", selection: $options.launchPlatform) {
                Text("Home").tag(Platform?.none)
                ForEach(Platform.allCases) { platform in
                    Text(verbatim: platform.name).tag(Platform?.some(platform))
                }
            }
        } footer: {
            Text("Sbu Social si apre direttamente su questo social.")
        }
    }
}

#Preview("Light") {
    Form {
        LaunchSection(options: OptionStore(defaults: UserDefaults(suiteName: "preview")!))
    }
}

#Preview("Dark") {
    Form {
        LaunchSection(options: OptionStore(defaults: UserDefaults(suiteName: "preview")!))
    }
    .preferredColorScheme(.dark)
}
