#if DEBUG
import SbuKit
import SwiftUI

/// The way into Taratura from Settings, in Debug builds only.
struct TuningSection: View {
    let model: ScanModel

    var body: some View {
        Section {
            NavigationLink {
                TuningView(model: model)
            } label: {
                Text(verbatim: "Taratura")
            }
        } header: {
            Text(verbatim: "Debug")
        }
    }
}

#Preview("Light") {
    NavigationStack {
        List {
            TuningSection(model: ScanModel(scanner: FixedScanner()))
        }
    }
}

#Preview("Dark") {
    NavigationStack {
        List {
            TuningSection(model: ScanModel(scanner: FixedScanner()))
        }
    }
    .preferredColorScheme(.dark)
}
#endif
