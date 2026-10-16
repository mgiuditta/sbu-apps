import SbuKit
import SwiftUI

/// Settings section for the ticks on the finder: the same two switches as its pills.
struct FeedbackSection: View {
    @Bindable var model: ScanModel

    var body: some View {
        Section {
            Toggle("Suono", isOn: $model.playsSound)
            Toggle("Vibrazione", isOn: $model.vibrates)
        } header: {
            Text("Durante la ricerca")
        } footer: {
            Text("Un tic che accelera quando ti avvicini, così cerchi senza guardare lo schermo. Il suono segue l'interruttore silenzioso.")
        }
    }
}

#Preview("Light") {
    List {
        FeedbackSection(model: ScanModel(scanner: FixedScanner()))
    }
}

#Preview("Dark") {
    List {
        FeedbackSection(model: ScanModel(scanner: FixedScanner()))
    }
    .preferredColorScheme(.dark)
}
