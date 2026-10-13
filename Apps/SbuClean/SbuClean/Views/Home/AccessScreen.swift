import SbuKit
import SwiftUI

/// The first screen: what Sbu Clean does in a line, and the Photos permission. When the user
/// said no, it says how to change it in Settings.
struct AccessScreen: View {
    let model: CleanModel

    @Environment(\.openURL) private var openURL
    @ScaledMetric(relativeTo: .largeTitle) private var symbolSize: CGFloat = 64

    private var isDenied: Bool {
        model.access == .denied
    }

    var body: some View {
        SbuToolField(
            "Sbu Clean",
            context: isDenied
                ? "Sbu Clean non può vedere le tue foto. Consenti l'accesso in Impostazioni, alla voce Foto."
                : "Libera spazio nella libreria Foto: scorri, rivedi, elimina. Tutto resta su questo iPhone."
        ) {
            Image(systemName: isDenied ? "photo.badge.exclamationmark" : "photo.on.rectangle.angled")
                .font(.system(size: symbolSize))
                .fontWeight(.medium)
                .foregroundStyle(.tint)
                .accessibilityHidden(true)
        } pills: {
            if isDenied {
                Button("Apri Impostazioni", action: openSettings)
                    .buttonStyle(SbuFieldPillStyle())
            } else {
                Button("Consenti l'accesso", action: requestAccess)
                    .buttonStyle(SbuFieldPillStyle())
            }
        }
    }

    private func requestAccess() {
        Task {
            await model.requestAccess()
        }
    }

    private func openSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            openURL(url)
        }
    }
}

#Preview("Da chiedere") {
    AccessScreen(model: .preview(access: .notDetermined))
        .tint(SbuTheme.accentClean)
}

#Preview("Negato, scuro") {
    AccessScreen(model: .preview(access: .denied))
        .tint(SbuTheme.accentClean)
        .preferredColorScheme(.dark)
}
