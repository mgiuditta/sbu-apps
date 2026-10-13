import SbuKit
import SwiftUI

/// One queue as a stack of cards: swipe right to keep, left to put in the bin.
///
/// Buttons do the same as the swipe, and VoiceOver has the same actions on the card. Nothing is
/// deleted here: marked items wait in the bin for the final review.
struct SwipeScreen: View {
    let model: CleanModel
    let source: SwipeSource

    @Environment(\.photoLibrary) private var library
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var deck: SwipeDeck?
    @State private var exitEdge = Edge.leading
    @State private var detailsItem: MediaItem?
    @State private var showsBin = false

    private var currentItem: MediaItem? {
        deck?.current.flatMap { model.itemsByID[$0] }
    }

    private var context: LocalizedStringKey {
        guard let deck else { return "Preparo la coda" }

        if deck.ids.isEmpty {
            return "Nessuna foto da vedere"
        }
        if deck.isDone {
            return "\(deck.ids.count) visti"
        }
        let date = currentItem?.creationDate?.formatted(date: .abbreviated, time: .omitted) ?? ""
        return "\(deck.number) di \(deck.ids.count) · \(date)"
    }

    var body: some View {
        VStack(spacing: SbuTheme.space3) {
            SpaceStat(label: "Nel cestino", bytes: model.trashBytes, context: context)
                // The photo is the point of this screen: the figure stops growing before it.
                .dynamicTypeSize(...DynamicTypeSize.accessibility1)

            ZStack {
                if let deck, deck.isDone {
                    SwipeDoneView(source: source, isEmptyQueue: deck.ids.isEmpty, binCount: model.state.trash.count, reviewBin: reviewBin)
                } else if let item = currentItem {
                    if let next = deck?.next.flatMap({ model.itemsByID[$0] }) {
                        SwipeCardContent(item: next)
                            .scaleEffect(0.94)
                            .opacity(0.6)
                            .accessibilityHidden(true)
                    }
                    SwipeCard(item: item, decide: decide, showDetails: { detailsItem = item })
                        .id(item.id)
                        .transition(.asymmetric(insertion: .opacity, removal: .move(edge: exitEdge).combined(with: .opacity)))
                } else {
                    ProgressView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            if deck?.isDone == false {
                SwipeControls(decide: decide)
            }
        }
        .padding(.horizontal, SbuTheme.space4)
        .padding(.bottom, SbuTheme.space3)
        .background(SbuTheme.surface)
        .navigationTitle(source.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Annulla l'ultima scelta", systemImage: "arrow.uturn.backward", action: undo)
                    .disabled(deck?.canUndo != true)
                    // In ink, as the shell's gear: the accent belongs to the figure's full stop.
                    .tint(SbuTheme.ink)
            }
        }
        .sensoryFeedback(.selection, trigger: deck?.number)
        .sheet(item: $detailsItem) { item in
            MediaDetailsSheet(item: item)
        }
        .navigationDestination(isPresented: $showsBin) {
            BinScreen(model: model)
        }
        .task {
            guard deck == nil else { return }

            await loadDeck()
        }
    }

    private func loadDeck() async {
        var albumItemIDs: [String] = []
        if case .album(let album) = source {
            albumItemIDs = await library.itemIDs(inAlbum: album.id)
        }
        deck = SwipeDeck(ids: model.queues.queue(for: source, albumItemIDs: albumItemIDs))
    }

    private func decide(_ decision: SwipeDecision) {
        guard let id = deck?.current else { return }

        exitEdge = decision == .trash ? .leading : .trailing
        withAnimation(reduceMotion ? nil : .snappy) {
            let previous = model.decide(decision, on: id)
            deck?.advance(previous: previous)
        }
    }

    private func undo() {
        withAnimation(reduceMotion ? nil : .snappy) {
            if let step = deck?.undo() {
                model.decide(step.previous, on: step.id)
            }
        }
    }

    private func reviewBin() {
        showsBin = true
    }
}

#Preview("Light") {
    SwipePreview()
}

#Preview("Dark") {
    SwipePreview()
        .preferredColorScheme(.dark)
}

private struct SwipePreview: View {
    @State private var model = CleanModel.preview

    var body: some View {
        NavigationStack {
            SwipeScreen(model: model, source: .recent)
        }
        .tint(SbuTheme.accentClean)
        .task { await model.reload() }
    }
}
