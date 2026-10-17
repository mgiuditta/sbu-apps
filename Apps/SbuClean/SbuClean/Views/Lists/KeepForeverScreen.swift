import SbuKit
import SwiftUI

/// The items you chose to keep forever: never proposed again, in any queue or category.
/// Swipe one to let it come back.
struct KeepForeverScreen: View {
    let model: CleanModel

    @ScaledMetric(relativeTo: .body) private var thumbnailSide: CGFloat = 56

    var body: some View {
        let items = model.items.filter { model.state.keepForever.contains($0.id) }
        Group {
            if items.isEmpty {
                EmptyScreen(sentence: "Scorrendo, tocca Tieni sempre: quella foto non ti verrà più proposta.")
            } else {
                list(items)
            }
        }
        .navigationTitle("Da tenere sempre")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func list(_ items: [MediaItem]) -> some View {
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
                        Button("Proponi di nuovo", systemImage: "arrow.uturn.backward") {
                            model.decide(nil, on: item.id)
                        }
                    }
                }
            } footer: {
                Text("Scorri un elemento verso sinistra e tocca Proponi di nuovo perché torni nelle code.")
            }
            .listRowBackground(SbuTheme.surfaceRaised)
        }
        .listStyle(.insetGrouped)
        // The figure starts where it does on the other screens.
        .contentMargins(.top, SbuTheme.space4, for: .scrollContent)
        .scrollContentBackground(.hidden)
        .background(SbuTheme.paper)
    }
}

#Preview("Light") {
    NavigationStack {
        KeepForeverScreen(model: .preview)
    }
    .environment(\.sbuAccent, .clean)
}

#Preview("Dark") {
    NavigationStack {
        KeepForeverScreen(model: .preview)
    }
    .environment(\.sbuAccent, .clean)
    .preferredColorScheme(.dark)
}
