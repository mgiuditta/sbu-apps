import SbuKit
import SwiftUI

/// The tool screen.
struct MainView: View {
    let model: CleanModel

    var body: some View {
        Text(verbatim: "\(model.items.count)")
            .task { await model.start() }
    }
}
