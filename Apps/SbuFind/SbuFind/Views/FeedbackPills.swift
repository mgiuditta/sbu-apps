import SbuKit
import SwiftUI

/// The two switches on the finder: the ticking sound and the ticking tap. Selected when on.
struct FeedbackPills: View {
    @Bindable var model: ScanModel

    var body: some View {
        Button("Suono", systemImage: model.playsSound ? "speaker.wave.2" : "speaker.slash", action: toggleSound)
            .buttonStyle(SbuFieldPillStyle(isSelected: model.playsSound))

        Button("Vibrazione", systemImage: model.vibrates ? "iphone.radiowaves.left.and.right" : "iphone.slash", action: toggleVibration)
            .buttonStyle(SbuFieldPillStyle(isSelected: model.vibrates))
    }

    private func toggleSound() {
        model.playsSound.toggle()
    }

    private func toggleVibration() {
        model.vibrates.toggle()
    }
}

#Preview("Light") {
    HStack {
        FeedbackPills(model: ScanModel(scanner: FixedScanner()))
    }
    .padding(SbuTheme.space4)
    .background(SbuTheme.paper)
}

#Preview("Dark") {
    HStack {
        FeedbackPills(model: ScanModel(scanner: FixedScanner()))
    }
    .padding(SbuTheme.space4)
    .background(SbuTheme.paper)
    .preferredColorScheme(.dark)
}
