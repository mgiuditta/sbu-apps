import SbuKit
import SwiftUI

/// The keys under the navigation area, three to a row: Back, Replay, Options, then the media keys.
/// A key the TV's protocol lacks stays in its place, dimmed, so the grid never moves.
struct KeyGridView: View {
    let session: RemoteSession

    static let rows: [[RemoteKey]] = [
        [.back, .replay, .options],
        [.rewind, .playPause, .fastForward],
    ]

    var body: some View {
        Grid(horizontalSpacing: SbuTheme.space4, verticalSpacing: SbuTheme.space3) {
            ForEach(Self.rows, id: \.self) { row in
                GridRow {
                    ForEach(row, id: \.self) { key in
                        RemoteKeyButton(key: key, session: session)
                            .frame(maxWidth: .infinity)
                    }
                }
            }
        }
    }
}

#Preview("Light") {
    KeyGridView(session: .preview)
        .padding(SbuTheme.space4)
        .tint(SbuTheme.ink)
}

#Preview("Dark") {
    KeyGridView(session: .preview)
        .padding(SbuTheme.space4)
        .tint(SbuTheme.ink)
        .preferredColorScheme(.dark)
}
