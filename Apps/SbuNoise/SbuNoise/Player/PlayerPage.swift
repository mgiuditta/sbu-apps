import SbuKit
import SwiftUI

/// One page of the player, on the squared paper: the sound's or mix's name as the screen's figure,
/// closed by the full stop, set while it plays, and its place in the list under it.
struct PlayerPage: View {
    let item: PlayerItem
    let position: Int
    let count: Int
    /// Whether this page is the one on screen and its sound is playing.
    let isPlaying: Bool

    var body: some View {
        SbuFigure(
            value: item.name,
            fullStop: isPlaying ? .set : .waiting,
            context: Text("\(position) di \(count)")
        )
        .padding(.horizontal, SbuTheme.space4)
        // Top-aligned: the figure snaps its baseline to the grid from where it starts.
        .padding(.top, SbuTheme.gridCell)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .sbuPaper(grid: true)
    }
}

#Preview("Light") {
    PlayerPage(item: .sound(Sound.generated[2]), position: 3, count: 5, isPlaying: true)
        .environment(\.sbuAccent, .noise)
}

#Preview("Dark") {
    PlayerPage(item: .mix(Mix(name: "Temporale", soundIDs: ["noise.pink"])), position: 1, count: 2, isPlaying: false)
        .environment(\.sbuAccent, .noise)
        .preferredColorScheme(.dark)
}
