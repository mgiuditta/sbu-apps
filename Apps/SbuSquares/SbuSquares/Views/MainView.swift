import SbuKit
import SwiftUI

/// The tool screen: the score, the board, the three pieces.
///
/// A piece follows the finger at board size, above it, with the shadow of where it lands and the
/// lines it completes in grey. If it does not fit it flies back to the tray. Tapping a piece and
/// then a cell does the same without dragging, and is how VoiceOver plays.
struct MainView: View {
    nonisolated static let space = "game"

    @Bindable var store: GameStore

    @State private var drag: PieceDrag?
    @State private var selectedSlot: Int?
    @State private var boardFrame = CGRect.zero
    @State private var clearDelays: [Cell: Double] = [:]
    /// Bumps when a drop completes lines: the `dot` haptic.
    @State private var linesCleared = 0
    @State private var isConfirmingNewGame = false
    /// The figure's size on the grid, grown into the room the layout leaves (ADR-0015: 72 to 144).
    @State private var figureSize: CGFloat = SbuTheme.gridCell * 3
    @State private var contentWidth: CGFloat = 0
    /// The points and combo of the last move that completed lines, shown over the board.
    @State private var feedback: (points: Int, combo: Int)?

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private var game: Game { store.game }
    private var boardCell: CGFloat { max(boardFrame.width / CGFloat(Board.size), 1) }
    private var trayCell: CGFloat { (boardCell * 0.5).rounded(.down) }

    /// The drop or tap target of the piece in play, for the shadow on the board.
    private var preview: Placement? {
        if let drag, let origin = drag.origin { return game.board.preview(drag.piece, at: origin) }
        return nil
    }

    var body: some View {
        VStack(alignment: .leading, spacing: SbuTheme.space3) {
                RecordBadge(record: max(store.record, game.score))
                ScoreFigure(score: game.score, beatsRecord: game.beatsRecord, size: figureSize)
                    .sbuClosure($store.isShowingClosure, word: "Battuto")
                BoardView(board: game.board, preview: preview, previewTone: drag?.tone ?? 0, clearDelays: clearDelays, canPlaceByTap: selectedSlot != nil, tap: placeSelected)
                    .overlay {
                        if let feedback {
                            ClearFeedback(points: feedback.points, combo: feedback.combo)
                                .transition(.opacity)
                        }
                    }
                    .onGeometryChange(for: CGRect.self) { $0.frame(in: .named(Self.space)) } action: { boardFrame = $0 }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    // The height the board's square leaves unused is room for the figure.
                    .onGeometryChange(for: CGFloat.self) { $0.size.height } action: { fitFigure(slack: $0 - boardFrame.height) }
                    .sbuAffectsFigure(game.score)
                    .sbuHaptic(.dot, trigger: linesCleared)
                if game.isOver {
                    GameOverView(game: game, shareText: ShareText.make(for: game), playAgain: store.startNewGame)
                        .transition(SbuMotion.transition(from: .bottom, reduceMotion: reduceMotion))
                } else {
                    TrayView(game: game, cell: trayCell, drag: drag, selectedSlot: selectedSlot, dragChanged: dragChanged, dragEnded: dragEnded, select: select)
                }
            }
            .padding(.horizontal, SbuTheme.space4)
            .padding(.bottom, SbuTheme.space2)
            .onGeometryChange(for: CGFloat.self) { $0.size.width - SbuTheme.space4 * 2 } action: { contentWidth = $0 }
            .onChange(of: boardFrame.width) { fitFigure(slack: 0) }
            .animation(SbuMotion.animation(SbuMotion.base, reduceMotion: reduceMotion), value: game.isOver)
        .overlay {
            if let drag {
                FloatingPiece(drag: drag, boardCell: boardCell, trayScale: trayCell / boardCell)
            }
        }
        .coordinateSpace(.named(Self.space))
        .sbuPaper()
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Nuova partita", systemImage: "arrow.counterclockwise", action: askForNewGame)
            }
        }
        .confirmationDialog("Iniziare una nuova partita?", isPresented: $isConfirmingNewGame, titleVisibility: .visible) {
            Button("Nuova partita", role: .destructive, action: store.startNewGame)
        } message: {
            Text("Questa partita finisce qui.")
        }
    }
}

private extension MainView {
    /// Grows the figure by whole grid cells into the room left under the tray, and shrinks it
    /// while the board is narrower than the screen: the board comes first.
    func fitFigure(slack: CGFloat) {
        let cell = SbuTheme.gridCell
        var size = figureSize
        if boardFrame.width > 0, boardFrame.width < contentWidth - 1 {
            size -= cell
        } else {
            size += (slack / cell).rounded(.down) * cell
        }
        figureSize = min(max(size, cell * 3), cell * 6)
    }

    func dragChanged(slot: Int, value: DragGesture.Value) {
        guard let piece = game.piece(in: slot), drag?.slot ?? slot == slot else { return }
        if drag == nil {
            selectedSlot = nil
            hideFeedback()
            drag = PieceDrag(slot: slot, piece: piece, tone: game.tone(in: slot) ?? 0, location: value.location, start: value.startLocation)
            withAnimation(SbuMotion.animation(SbuMotion.spring, reduceMotion: reduceMotion)) {
                drag?.isLifted = true
            }
        }
        drag?.location = value.location
        let frame = DropTarget.pieceFrame(width: piece.width, height: piece.height, at: value.location, cell: boardCell)
        let origin = DropTarget.origin(of: frame, on: boardFrame)
        drag?.origin = game.board.canPlace(piece, at: origin) ? origin : nil
    }

    func dragEnded(slot: Int, value: DragGesture.Value) {
        guard let current = drag, current.slot == slot else { return }
        let isTap = hypot(value.translation.width, value.translation.height) < SbuTheme.space2
        if let origin = current.origin, !isTap {
            drag = nil
            place(slot: slot, at: origin)
        } else {
            if isTap { select(slot: slot) }
            withAnimation(SbuMotion.animation(SbuMotion.spring, reduceMotion: reduceMotion)) {
                drag?.location = current.start
                drag?.isLifted = false
                drag?.origin = nil
            } completion: {
                drag = nil
            }
        }
    }

    func select(slot: Int) {
        selectedSlot = selectedSlot == slot ? nil : slot
        hideFeedback()
    }

    func hideFeedback() {
        withAnimation(SbuMotion.animation(SbuMotion.short, reduceMotion: reduceMotion)) {
            feedback = nil
        }
    }

    func placeSelected(at cell: Cell) {
        guard let slot = selectedSlot else { return }
        place(slot: slot, at: cell)
    }

    func place(slot: Int, at origin: Cell) {
        guard let placement = store.place(slot: slot, at: origin) else { return }
        selectedSlot = nil
        clearDelays = Self.wave(of: placement)
        guard placement.lineCount > 0 else { return }
        linesCleared += 1
        let combo = game.combo.count
        withAnimation(SbuMotion.animation(SbuMotion.spring, reduceMotion: reduceMotion)) {
            feedback = (game.lastGain, combo)
        }
        let announcement = combo > 1
            ? String(localized: "Più \(game.lastGain) punti, combo \(combo)")
            : String(localized: "Più \(game.lastGain) punti")
        AccessibilityNotification.Announcement(announcement).post()
    }

    func askForNewGame() {
        if game.isOver || game.score == 0 {
            store.startNewGame()
        } else {
            isConfirmingNewGame = true
        }
    }

    func endInteraction() {
        drag = nil
        selectedSlot = nil
    }

    /// Each emptied cell waits a little more the farther it is from the piece that completed its line.
    static func wave(of placement: Placement) -> [Cell: Double] {
        let center = placement.covered.reduce((row: 0.0, column: 0.0)) { sum, cell in
            (sum.row + Double(cell.row), sum.column + Double(cell.column))
        }
        let count = Double(max(placement.covered.count, 1))
        return placement.cleared.reduce(into: [:]) { delays, cell in
            let distance = abs(Double(cell.row) - center.row / count) + abs(Double(cell.column) - center.column / count)
            delays[cell] = distance * SbuTheme.motionShort / 6
        }
    }
}

#Preview("Light") {
    NavigationStack {
        MainView(store: GameStore(defaults: UserDefaults(suiteName: "preview.light")!))
    }
    .environment(\.sbuAccent, .squares)
    .tint(SbuTheme.ink)
}

#Preview("Dark") {
    NavigationStack {
        MainView(store: GameStore(defaults: UserDefaults(suiteName: "preview.dark")!))
    }
    .environment(\.sbuAccent, .squares)
    .tint(SbuTheme.ink)
    .preferredColorScheme(.dark)
}
