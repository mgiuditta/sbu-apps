import SbuKit
import SwiftUI

/// The dashboard: the space you can free as the one figure, the iPhone's storage, every way to
/// clean below, the timeline and the bin at the bottom.
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
            return "Cerco doppioni e foto simili: \(done) di \(total)"
        }
        return "Su \(model.items.count) foto e video"
    }

    var body: some View {
        let figure = SpaceFigure(bytes: model.freeableBytes)
        SbuToolField("Spazio liberabile", value: figure.value, format: figure.format, unit: figure.unit, context: context) {
            VStack(spacing: SbuTheme.space3) {
                if let storage = model.storage {
                    StorageBar(storage: storage)
                        .padding(.horizontal, SbuTheme.space4)
                }
                HomeList(model: model)
                    // The list's own inset already makes the margin.
                    .padding(.horizontal, -SbuTheme.space4)
            }
            .frame(maxHeight: .infinity)
            .layoutPriority(1)
        } pills: {
            NavigationLink(value: Route.months) {
                Text("Scorri le foto")
                    .fixedSize(horizontal: false, vertical: true)
            }
            .buttonStyle(SbuFieldPillStyle())
            NavigationLink(value: Route.bin) {
                Text("Cestino: \(model.state.trash.count)")
                    .fixedSize(horizontal: false, vertical: true)
            }
            .buttonStyle(SbuFieldPillStyle())
        }
        .navigationDestination(for: Route.self) { route in
            RouteView(route: route, model: model)
        }
        // The tool screen does not scroll: past this size the figure would leave no room for
        // the list. Every screen it opens follows the largest sizes.
        .dynamicTypeSize(...DynamicTypeSize.accessibility1)
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
