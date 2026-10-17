import SbuKit
import SwiftUI

/// The first screen: what Sbu Clean does in a line, and the Photos permission, asked only when
/// you tap Continua. When you said no, it says how to change it in Settings. No figure yet, so
/// no full stop: there is nothing to count before the library opens.
struct AccessScreen: View {
    let model: CleanModel

    @Environment(\.openURL) private var openURL

    private var isDenied: Bool {
        model.access == .denied
    }

    /// The metadata line under the title: the app and today's date.
    private var cartiglio: String {
        String(localized: "Sbu · Clean · \(Date.now.formatted(.dateTime.weekday(.abbreviated).day().month(.abbreviated)))")
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: SbuTheme.space6) {
                SbuScreenTitle("Accesso alle foto", cartiglio: cartiglio)

                Text(isDenied
                     ? "Sbu Clean non può vedere le tue foto. Consenti l'accesso in Impostazioni, alla voce Foto."
                     : "Libera spazio nella libreria Foto: scorri, rivedi, elimina. Tutto resta su questo iPhone.")
                    .font(SbuTheme.body)
                    .foregroundStyle(SbuTheme.ink)
                    .fixedSize(horizontal: false, vertical: true)

                if isDenied {
                    Button("Apri Impostazioni", action: openSettings)
                        .buttonStyle(.borderedProminent)
                        .buttonBorderShape(.roundedRectangle(radius: SbuTheme.radiusCard))
                } else {
                    Button("Continua", action: requestAccess)
                        .buttonStyle(.borderedProminent)
                        .buttonBorderShape(.roundedRectangle(radius: SbuTheme.radiusCard))
                }
            }
            .padding(.horizontal, SbuTheme.space4)
            .padding(.vertical, SbuTheme.space4)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .scrollBounceBehavior(.basedOnSize)
        // The first run is a paper area: the grid shows.
        .sbuPaper(grid: true)
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
        .tint(SbuTheme.ink)
}

#Preview("Negato, scuro") {
    AccessScreen(model: .preview(access: .denied))
        .tint(SbuTheme.ink)
        .preferredColorScheme(.dark)
}
