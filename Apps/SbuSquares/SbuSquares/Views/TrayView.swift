import SbuKit
import SwiftUI

/// The three pieces on offer. Drag one onto the board, or tap it and then tap a cell.
struct TrayView: View {
    let game: Game
    let cell: CGFloat
    let drag: PieceDrag?
    let selectedSlot: Int?
    let dragChanged: (Int, DragGesture.Value) -> Void
    let dragEnded: (Int, DragGesture.Value) -> Void
    let select: (Int) -> Void

    var body: some View {
        HStack(spacing: SbuTheme.space2) {
            ForEach(0..<3, id: \.self) { slot in
                let piece = game.piece(in: slot)
                TraySlot(
                    slot: slot,
                    piece: piece,
                    tone: game.tone(in: slot) ?? 0,
                    cell: cell,
                    isDragged: drag?.slot == slot,
                    fits: piece.map(game.board.hasRoom(for:)) ?? false,
                    isSelected: selectedSlot == slot,
                    select: { select(slot) }
                )
                .gesture(
                    DragGesture(minimumDistance: 0, coordinateSpace: .named(MainView.space))
                        .onChanged { dragChanged(slot, $0) }
                        .onEnded { dragEnded(slot, $0) },
                    including: piece == nil ? .none : .all
                )
            }
        }
        .frame(height: cell * 5 + SbuTheme.space4)
    }
}

#Preview("Light") {
    TrayView(game: Game(mode: .free, seed: 3, recordToBeat: 0), cell: 22, drag: nil, selectedSlot: nil, dragChanged: { _, _ in }, dragEnded: { _, _ in }, select: { _ in })
        .sbuPaper()
}

#Preview("Dark") {
    TrayView(game: Game(mode: .free, seed: 4, recordToBeat: 0), cell: 22, drag: nil, selectedSlot: 1, dragChanged: { _, _ in }, dragEnded: { _, _ in }, select: { _ in })
        .sbuPaper()
        .preferredColorScheme(.dark)
}
