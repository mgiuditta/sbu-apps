import SbuKit
import SwiftUI

/// The controls under the camera: torch, a code from a photo, the other camera.
struct ScanPills: View {
    let model: ScannerModel
    let choosePhoto: () -> Void

    var body: some View {
        if model.state == .running, model.info?.hasTorch == true {
            Button(action: model.toggleTorch) {
                PillLabel(title: "Torcia", systemImage: model.isTorchOn ? "flashlight.on.fill" : "flashlight.off.fill")
            }
            .buttonStyle(SbuFieldPillStyle(isSelected: model.isTorchOn))
            .accessibilityValue(model.isTorchOn ? Text("Accesa") : Text("Spenta"))
        }
        Button(action: choosePhoto) {
            PillLabel(title: "Da una foto", systemImage: "photo")
        }
        .buttonStyle(SbuFieldPillStyle())
        if model.state == .running {
            Button {
                Task { await model.switchCamera() }
            } label: {
                PillLabel(title: model.position == .back ? "Frontale" : "Posteriore", systemImage: "arrow.triangle.2.circlepath.camera")
            }
            .buttonStyle(SbuFieldPillStyle())
            .accessibilityLabel(model.position == .back ? "Usa la fotocamera frontale" : "Usa la fotocamera posteriore")
        }
    }
}

#Preview("Light") {
    HStack { ScanPills(model: ScannerModel(isDemo: true)) {} }
}

#Preview("Dark") {
    HStack { ScanPills(model: ScannerModel(isDemo: true)) {} }
        .preferredColorScheme(.dark)
}
