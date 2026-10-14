import SbuKit
import SwiftUI

/// What the frame says when there is no picture: no permission, or no camera.
struct CameraMessage: View {
    let state: CameraState
    @Environment(\.openURL) private var openURL

    var body: some View {
        VStack(spacing: SbuTheme.space3) {
            Image(systemName: state == .denied ? "camera.badge.ellipsis" : "camera")
                .font(.largeTitle)
                .fontWeight(.medium)
                .foregroundStyle(SbuTheme.inkMuted)
                .accessibilityHidden(true)
            Text(state == .denied ? "Sbu Scanner non può usare la fotocamera." : "La fotocamera non è disponibile.")
                .font(SbuTheme.headline)
                .foregroundStyle(SbuTheme.ink)
            Text(state == .denied ? "Puoi permetterlo in Impostazioni, o leggere un codice da una foto." : "Puoi leggere un codice da una foto.")
                .font(SbuTheme.subheadline)
                .foregroundStyle(SbuTheme.inkMuted)
            if state == .denied, let settings = URL(string: UIApplication.openSettingsURLString) {
                Button("Apri Impostazioni") { openURL(settings) }
                    .buttonStyle(SbuFieldPillStyle())
            }
        }
        .multilineTextAlignment(.center)
        .padding(SbuTheme.space4)
    }
}

#Preview("Light") {
    CameraMessage(state: .denied)
}

#Preview("Dark") {
    CameraMessage(state: .unavailable)
        .preferredColorScheme(.dark)
}
