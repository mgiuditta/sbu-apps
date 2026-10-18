import SbuKit
import SwiftUI

/// The 8 × 8 board on a white card, with the shadow of the dragged piece and the lines it would complete.
struct BoardView: View {
    let board: Board
    /// Where the dragged or selected piece would land.
    let preview: Placement?
    let clearDelays: [Cell: Double]
    /// Whether tapping a cell puts the selected piece there.
    let canPlaceByTap: Bool
    let tap: (Cell) -> Void

    var body: some View {
        let covered = Set(preview?.covered ?? [])
        let completing = preview?.cleared ?? []
        Grid(horizontalSpacing: 0, verticalSpacing: 0) {
            ForEach(0..<Board.size, id: \.self) { row in
                GridRow {
                    ForEach(0..<Board.size, id: \.self) { column in
                        let cell = Cell(row: row, column: column)
                        BoardCellView(look: look(of: cell, covered: covered, completing: completing), clearDelay: clearDelays[cell] ?? 0)
                            .contentShape(.rect)
                            .onTapGesture { tap(cell) }
                            .accessibilityElement()
                            .accessibilityLabel("Riga \(row + 1), colonna \(column + 1)")
                            .accessibilityValue(board[cell] ? Text("Piena") : Text("Vuota"))
                            .accessibilityAddTraits(canPlaceByTap ? .isButton : [])
                            .accessibilityHint(canPlaceByTap ? Text("Mette qui l'angolo in alto a sinistra del pezzo scelto.") : Text(verbatim: ""))
                    }
                }
            }
        }
        .aspectRatio(1, contentMode: .fit)
        .background {
            BoardLines()
                .background(SbuTheme.surfaceRaised)
        }
        .clipShape(.rect(cornerRadius: SbuTheme.radiusCard))
        .overlay {
            RoundedRectangle(cornerRadius: SbuTheme.radiusCard)
                .strokeBorder(SbuTheme.ink, lineWidth: SbuTheme.rowMarkStroke)
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Griglia")
    }

    private func look(of cell: Cell, covered: Set<Cell>, completing: Set<Cell>) -> CellLook {
        if completing.contains(cell) { return .completing }
        if covered.contains(cell) { return .shadow }
        return board[cell] ? .filled : .empty
    }
}

#Preview("Light") {
    BoardPreview()
}

#Preview("Dark") {
    BoardPreview()
        .preferredColorScheme(.dark)
}

private struct BoardPreview: View {
    var body: some View {
        var game = Game(mode: .free, seed: 7, recordToBeat: 0)
        for _ in 0..<6 {
            for slot in 0..<3 {
                guard let piece = game.piece(in: slot), let cell = Board.allCells.first(where: { game.board.canPlace(piece, at: $0) }) else { continue }
                game.place(slot: slot, at: cell)
            }
        }
        let preview = game.piece(in: 0).flatMap { piece in
            Board.allCells.lazy.compactMap { game.board.preview(piece, at: $0) }.first
        }
        return BoardView(board: game.board, preview: preview, clearDelays: [:], canPlaceByTap: false) { _ in }
            .padding(SbuTheme.space4)
            .sbuPaper()
    }
}
