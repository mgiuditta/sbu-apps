import SbuKit
import SwiftUI

/// Tracing, DrawinGrid's AR Sketch: the camera looks at the paper, the photo and the grid float
/// over it, see-through, and you follow the lines with the pencil. The iPhone stands on a
/// support above the sheet, so the screen stays awake. There is no drawing on the screen.
///
/// Before the first use it says what the camera is for, then the system asks.
struct TraceView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL
    @Environment(\.scenePhase) private var scenePhase

    @Bindable var model: GridModel

    @State private var camera = TraceCamera()
    /// Set by "Usa la fotocamera" on the first use, when the system has not asked yet.
    @State private var wantsCamera = false
    @State private var isLocked = false

    private var shouldRun: Bool {
        scenePhase == .active && (camera.access == .allowed || wantsCamera)
    }

    var body: some View {
        ZStack(alignment: .topTrailing) {
            content

            Button("Chiudi", systemImage: "xmark", action: close)
                .labelStyle(.iconOnly)
                .buttonStyle(SbuFieldPillStyle())
                .padding(SbuTheme.space4)
        }
        .statusBarHidden()
        .persistentSystemOverlays(.hidden)
        .task(id: shouldRun) {
            guard shouldRun else { return }
            await camera.run()
        }
        .onChange(of: scenePhase) {
            camera.refresh()
        }
        .onAppear(perform: keepAwake)
        .onDisappear(perform: allowSleep)
    }

    @ViewBuilder private var content: some View {
        switch camera.access {
        case .allowed:
            TraceStage(model: model, session: camera.session, isLocked: $isLocked)
        case .notDetermined:
            NoticeView(
                title: "Ricalca sulla carta",
                message: "Metti l'iPhone su un supporto sopra il foglio: vedi la carta con la fotocamera, e la foto con la griglia sopra. Segui le linee con la matita guardando lo schermo. Quello che la fotocamera vede resta sullo schermo: non viene salvato.",
                systemImage: "camera.viewfinder"
            ) {
                SbuButton("Usa la fotocamera", action: useCamera)
            }
        case .denied:
            NoticeView(
                title: "Fotocamera non consentita",
                message: "Per ricalcare, consenti a Sbu Grid di usare la fotocamera in Impostazioni.",
                systemImage: "camera"
            ) {
                SbuButton("Apri Impostazioni", action: openSettings)
            }
        case .unavailable:
            NoticeView(
                title: "Fotocamera non disponibile",
                message: "Per ricalcare serve la fotocamera posteriore. Puoi sempre copiare la foto cella per cella dallo schermo.",
                systemImage: "camera"
            ) {
                EmptyView()
            }
        }
    }

    private func useCamera() {
        wantsCamera = true
    }

    private func openSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            openURL(url)
        }
    }

    private func close() {
        dismiss()
    }

    /// On a support, nobody touches the screen: it must not go dark mid-line.
    private func keepAwake() {
        UIApplication.shared.isIdleTimerDisabled = true
    }

    private func allowSleep() {
        UIApplication.shared.isIdleTimerDisabled = false
    }
}

#Preview("Light") {
    TraceView(model: .forLaunch(.demo))
        .tint(SbuTheme.accentGrid)
}

#Preview("Dark") {
    TraceView(model: .forLaunch(.demo))
        .tint(SbuTheme.accentGrid)
        .preferredColorScheme(.dark)
}
