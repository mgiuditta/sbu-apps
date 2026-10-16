// iOS only: alternate icons and the settings have no place on Apple Watch.
#if os(iOS)

import SwiftUI
import UIKit

/// Impostazioni → Icona: the engraved icon (Carta) or the one alternate, Inversa (paper on ink),
/// the same for every Sbu app.
///
/// Shows only when the app ships `AppIcon-Inversa` and the system supports alternate icons.
public struct SbuIconPicker: View {
    /// The asset name of the alternate icon every app ships.
    public static let alternateIconName = "AppIcon-Inversa"

    @State private var selection: String?
    @State private var failed = false

    public init() {}

    /// Whether this build of the app has the alternate icon.
    public static var isAvailable: Bool {
        let icons = Bundle.main.object(forInfoDictionaryKey: "CFBundleIcons") as? [String: Any]
        let alternates = icons?["CFBundleAlternateIcons"] as? [String: Any]
        return alternates?[alternateIconName] != nil && UIApplication.shared.supportsAlternateIcons
    }

    public var body: some View {
        Picker(selection: $selection) {
            Text("Carta", bundle: SbuTheme.bundle).tag(String?.none)
            Text("Inversa", bundle: SbuTheme.bundle).tag(String?.some(Self.alternateIconName))
        } label: {
            Text("Icona", bundle: SbuTheme.bundle)
        }
        .pickerStyle(.inline)
        .labelsHidden()
        .onAppear {
            selection = UIApplication.shared.alternateIconName
        }
        .onChange(of: selection) { _, name in
            guard name != UIApplication.shared.alternateIconName else { return }
            Task { await apply(name) }
        }
        .alert(Text("Icona non cambiata", bundle: SbuTheme.bundle), isPresented: $failed) {
            Button(String(localized: "OK", bundle: SbuTheme.bundle)) {}
        }
    }

    private func apply(_ name: String?) async {
        do {
            try await UIApplication.shared.setAlternateIconName(name)
        } catch {
            selection = UIApplication.shared.alternateIconName
            failed = true
        }
    }
}

#Preview("Light") {
    List { SbuIconPicker() }
}

#Preview("Dark") {
    List { SbuIconPicker() }
        .preferredColorScheme(.dark)
}

#endif
