import SbuKit
import SwiftUI

/// The items you chose to keep forever: never proposed again, in any queue or category.
/// Swipe one to let it come back.
struct KeepForeverScreen: View {
    let model: CleanModel

    @ScaledMetric(relativeTo: .body) private var thumbnailSide: CGFloat = 56

    var body: some View {
        let items = model.items.filter { model.state.keepForever.contains($0.id) }
        List {
            Section {
                SpaceStat(label: "Da tenere sempre", bytes: model.bytes(of: items.map(\.id)), context: "\(items.count) elementi protetti")
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
            }

            Section {
                ForEach(items) { item in
                    HStack(spacing: SbuTheme.space3) {
                        MediaThumbnail(id: item.id, side: thumbnailSide)
                            .frame(width: thumbnailSide, height: thumbnailSide)
                            .clipShape(.rect(cornerRadius: SbuTheme.radiusSm))
                        Text(item.spokenDescription)
                            .font(SbuTheme.subheadline)
                            .foregroundStyle(SbuTheme.ink)
                    }
                    .swipeActions {
                        Button("Non tenere più", systemImage: "lock.open") {
                            model.decide(nil, on: item.id)
                        }
                    }
                }
            } footer: {
                Text(items.isEmpty
                     ? "Scorrendo, tocca Tieni sempre: quella foto non ti verrà più proposta."
                     : "Scorri un elemento verso sinistra perché ti venga proposto di nuovo.")
            }
            .listRowBackground(SbuTheme.surfaceRaised)
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
        .background(SbuTheme.surface)
        .navigationTitle("Da tenere sempre")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview("Light") {
    NavigationStack {
        KeepForeverScreen(model: .preview)
    }
    .tint(SbuTheme.accentClean)
}

#Preview("Dark") {
    NavigationStack {
        KeepForeverScreen(model: .preview)
    }
    .tint(SbuTheme.accentClean)
    .preferredColorScheme(.dark)
}
