import SbuKit
import SwiftUI

/// The tool screen: the score, the grid, the tools and the digits.
///
/// Select a cell, then tap a digit. With Note on, the digit goes in the cell's notes. The game is
/// saved after every move; the time runs only while the app is in front.
struct MainView: View {
    @Bindable var store: GameStore

    /// Why the last tap changed nothing, under the score until the next one.
    @State private var message: LocalizedStringResource?
    @State private var proposed = Difficulty.fallback
    @State private var pendingStart: PendingStart?
    /// The figure's size on the grid, grown into the room the layout leaves (ADR-0015: 72 to 144).
    @State private var figureSize: CGFloat = SbuTheme.gridCell * 3
    @State private var contentWidth: CGFloat = 0
    @State private var boardWidth: CGFloat = 0

    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        Group {
            if let game = store.game {
                playing(game)
            } else {
                SbuEmpty(sentence: "Scegli una difficoltà e riempi la griglia.") {
                    newGameMenu {
                        Text("Nuova partita")
                    }
                    .buttonStyle(SbuButtonStyle(.primary))
                }
                .padding(.horizontal, SbuTheme.space4)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            }
        }
        .sbuPaper()
        .toolbar {
            if store.game != nil {
                ToolbarItem(placement: .topBarTrailing) {
                    newGameMenu {
                        Label("Nuova partita", systemImage: "plus")
                    }
                }
            }
        }
        .alert("Iniziare una nuova partita?", isPresented: isConfirmingStart, presenting: pendingStart) { start in
            Button("Annulla", role: .cancel) {}
            Button("Nuova partita", role: .destructive) { begin(start) }
        } message: { _ in
            Text("Questa partita finisce qui.")
        }
        .task(id: scenePhase) {
            guard scenePhase == .active else {
                store.tick(now: nil)
                return
            }
            store.tick(now: .now)
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(1))
                store.tick(now: .now)
            }
        }
        .onAppear { proposed = store.proposedDifficulty() }
        .onChange(of: store.game?.isOver) { proposed = store.proposedDifficulty() }
    }

    private func playing(_ game: Game) -> some View {
        VStack(alignment: .leading, spacing: SbuTheme.space3) {
            SbuScreenTitle("Sudoku", cartiglio: cartiglio(game))
            VStack(alignment: .leading, spacing: 0) {
                ScoreFigure(score: game.score, beatsRecord: store.beatsRecord, size: figureSize)
                    .sbuClosure($store.isShowingClosure, word: "Battuto")
                StatusLine(game: game, preferences: store.preferences, message: message ?? wrongSolutionMessage(game))
            }
            BoardView(game: game, preferences: store.preferences, select: select)
                .onGeometryChange(for: CGFloat.self) { $0.size.width } action: { boardWidth = $0 }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                // The height the board's square leaves unused is room for the figure.
                .onGeometryChange(for: CGFloat.self) { $0.size.height } action: { fitFigure(slack: $0 - boardWidth) }
                .sbuAffectsFigure(game.score)
                .sbuHaptic(.tick, trigger: game.selected)
                .sbuHaptic(.dot, trigger: game.score)
            if game.isOver {
                EndView(game: game, takeSecondChance: store.takeSecondChance) {
                    newGameMenu {
                        Text("Nuova partita")
                    }
                    .buttonStyle(SbuButtonStyle(game.failure == nil ? .primary : .secondary))
                }
                .transition(SbuMotion.transition(from: .bottom, reduceMotion: reduceMotion))
            } else {
                ActionBar(game: game, undo: { act { store.undo() } }, erase: { act { show(store.erase()) } }, toggleNoting: { act { store.toggleNoting() } }, hint: { act { show(store.hint()) } })
                DigitPad(game: game, disablesUsedDigits: store.preferences.disablesUsedDigits) { digit in
                    act { show(store.enter(digit)) }
                }
            }
        }
        .padding(.horizontal, SbuTheme.space4)
        .padding(.bottom, SbuTheme.space2)
        .onGeometryChange(for: CGFloat.self) { $0.size.width - SbuTheme.space4 * 2 } action: { contentWidth = $0 }
        .onChange(of: boardWidth) { fitFigure(slack: 0) }
        .animation(SbuMotion.animation(SbuMotion.base, reduceMotion: reduceMotion), value: game.isOver)
    }

    private func newGameMenu<Label: View>(@ViewBuilder label: @escaping () -> Label) -> some View {
        NewGameMenu(
            proposed: proposed,
            hasPlayedDaily: store.hasPlayedDaily(),
            start: { ask(.difficulty($0)) },
            startDaily: { ask(.daily) },
            label: label
        )
    }
}

private extension MainView {
    enum PendingStart {
        case difficulty(Difficulty)
        case daily
    }

    var isConfirmingStart: Binding<Bool> {
        Binding { pendingStart != nil } set: { if !$0 { pendingStart = nil } }
    }

    func cartiglio(_ game: Game) -> String {
        let kind = game.day == nil ? String(localized: game.difficulty.name) : String(localized: "Del giorno")
        let record = store.record(for: game.difficulty)
        guard record > 0 else { return String(localized: "Sbu · Sudoku · \(kind)") }
        return String(localized: "Sbu · Sudoku · \(kind) · Record \(record.formatted())")
    }

    /// With every check off, nothing says a filled grid is wrong but this.
    func wrongSolutionMessage(_ game: Game) -> LocalizedStringResource? {
        let preferences = store.preferences
        guard game.isFilledWrong, !game.hasMistakeLimit, !preferences.rules.checksMistakes, !preferences.highlightsDuplicates else { return nil }
        return "La griglia è piena, ma qualcosa non torna."
    }

    func select(_ cell: Int) {
        act { store.select(cell) }
    }

    func act(_ action: () -> Void) {
        message = nil
        action()
    }

    func show(_ entry: Entry) {
        switch entry {
        case .alreadyCorrect: message = "Questa cifra è già giusta."
        case .given: message = "Questa cifra non si cambia."
        default: return
        }
        if let message { AccessibilityNotification.Announcement(String(localized: message)).post() }
    }

    func ask(_ start: PendingStart) {
        if let game = store.game, !game.isOver, game.canUndo || game.score > 0 {
            pendingStart = start
        } else {
            begin(start)
        }
    }

    func begin(_ start: PendingStart) {
        message = nil
        Task {
            switch start {
            case .difficulty(let difficulty): await store.startGame(difficulty)
            case .daily: await store.startDaily()
            }
        }
    }

    /// Grows the figure by whole grid cells into the room left above the tools, and shrinks it
    /// while the board is narrower than the screen: the board comes first.
    func fitFigure(slack: CGFloat) {
        let cell = SbuTheme.gridCell
        var size = figureSize
        if boardWidth > 0, boardWidth < contentWidth - 1 {
            size -= cell
        } else {
            size += (slack / cell).rounded(.down) * cell
        }
        figureSize = min(max(size, cell * 3), cell * 6)
    }
}

#Preview("Light") {
    NavigationStack {
        MainView(store: GameStore(defaults: UserDefaults(suiteName: "preview.light")!))
    }
    .environment(\.sbuAccent, .sudoku)
    .tint(SbuTheme.ink)
}

#Preview("Dark") {
    NavigationStack {
        MainView(store: GameStore(defaults: UserDefaults(suiteName: "preview.dark")!))
    }
    .environment(\.sbuAccent, .sudoku)
    .tint(SbuTheme.ink)
    .preferredColorScheme(.dark)
}
