import SbuKit
import SwiftUI
import WidgetKit

/// The free space on paper: the figure closed by the full stop, and what you can free under it.
/// The stop waits while the system does not say how much space is free.
struct SpaceWidgetView: View {
    let entry: SpaceEntry

    var body: some View {
        let figure = entry.storage.map { SpaceFigure(bytes: $0.availableBytes) }
        SbuWidgetFigure(
            value: figure?.number ?? "–",
            unit: figure?.figureUnit,
            label: label,
            fullStop: figure == nil ? .waiting : .set,
            accent: .clean
        )
    }

    private var label: Text {
        if let bytes = entry.freeableBytes {
            Text("Spazio libero · puoi liberare \(bytes.sizeText)")
        } else {
            Text("Spazio libero · apri Sbu Clean per cercare")
        }
    }
}

#Preview("Piccolo", as: .systemSmall) {
    SpaceWidget()
} timeline: {
    SpaceEntry.sample
    SpaceEntry(date: .now, storage: SpaceEntry.sample.storage, freeableBytes: nil)
}

#Preview("Medio", as: .systemMedium) {
    SpaceWidget()
} timeline: {
    SpaceEntry.sample
}

#Preview("Piccolo, senza dati", as: .systemSmall) {
    SpaceWidget()
} timeline: {
    SpaceEntry(date: .now, storage: nil, freeableBytes: nil)
}
