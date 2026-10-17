import SbuKit
import SwiftUI

/// The dashboard: the space you can free as the one figure, every way to clean below, and the
/// swipe and the bin always at hand at the bottom. The page scrolls, so it works at every text
/// size.
///
/// The full stop waits while the library is read, measured and scanned, and sets when the
/// figure is final.
struct HomeScreen: View {
    let model: CleanModel

    private var isCounting: Bool {
        if !model.hasLoaded || model.unmeasuredCount > 0 { return true }
        if case .running = model.scan { return true }
        return false
    }

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
        return "liberabili · \(model.summary.itemCount) foto e video"
    }

    /// The metadata line under the title: the app and today's date.
    private var cartiglio: String {
        String(localized: "Sbu · Clean · \(Date.now.formatted(.dateTime.weekday(.abbreviated).day().month(.abbreviated)))")
    }

    var body: some View {
        let figure = SpaceFigure(bytes: model.summary.freeableBytes)
        ScrollView {
            VStack(alignment: .leading, spacing: SbuTheme.space6) {
                SbuScreenTitle("Clean", cartiglio: cartiglio)
                SbuFigure(
                    value: figure.number,
                    unit: figure.figureUnit,
                    fullStop: isCounting ? .waiting : .set,
                    context: Text(context),
                    accessibilityLabel: Text("Spazio liberabile, \(model.summary.freeableBytes.sizeText), \(Text(context))")
                )
                HomeList(model: model)
            }
            .padding(.horizontal, SbuTheme.space4)
            .padding(.top, SbuTheme.space4)
            .padding(.bottom, SbuTheme.space6)
            // Inside the scroll, so the grid and the figure's baseline move together.
            .sbuPaper(grid: true)
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
    .environment(\.sbuAccent, .clean)
}

#Preview("Dark") {
    NavigationStack {
        MainView(model: .preview)
    }
    .environment(\.sbuAccent, .clean)
    .preferredColorScheme(.dark)
}
