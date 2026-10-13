import SbuKit
import SwiftUI

/// The dashboard: the space you can free as the one figure, the iPhone's storage, every way to
/// clean below, and the swipe and the bin always at hand at the bottom. The page scrolls, so
/// it works at every text size.
struct HomeScreen: View {
    let model: CleanModel

    private var context: LocalizedStringKey {
        if !model.hasLoaded {
            return "Leggo la libreria"
        }
        if model.unmeasuredCount > 0 {
            return "Misuro \(model.unmeasuredCount) elementi"
        }
        if case .running(let done, let total) = model.scan {
            return "Cerco duplicati e foto simili: \(done) di \(total)"
        }
        return "Su \(model.summary.itemCount) foto e video"
    }

    var body: some View {
        let figure = SpaceFigure(bytes: model.summary.freeableBytes)
        ScrollView {
            SbuToolField("Spazio liberabile", value: figure.number, format: figure.format, unit: figure.unit, context: context) {
                VStack(spacing: SbuTheme.space6) {
                    if let storage = model.storage {
                        // On the same guide as the group headers and the rows' text.
                        StorageBar(storage: storage)
                            .padding(.horizontal, SbuTheme.space4)
                    }
                    HomeList(model: model)
                }
            } pills: {
                EmptyView()
            }
        }
        .scrollBounceBehavior(.basedOnSize)
        // The two ways in stay at hand while the page scrolls.
        .bottomAction {
            HomePills(binCount: model.state.trash.count)
        }
        .navigationDestination(for: Route.self) { route in
            RouteView(route: route, model: model)
        }
    }
}

#Preview("Light") {
    NavigationStack {
        MainView(model: .preview)
    }
    .tint(SbuTheme.accentClean)
}

#Preview("Dark") {
    NavigationStack {
        MainView(model: .preview)
    }
    .tint(SbuTheme.accentClean)
    .preferredColorScheme(.dark)
}
