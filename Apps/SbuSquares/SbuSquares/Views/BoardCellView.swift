import SbuKit
import SwiftUI

/// One square of the board: an ink square inset in its cell, or nothing.
struct BoardCellView: View {
    let look: CellLook
    /// How long an emptied cell waits before fading, so a completed line clears as a wave.
    let clearDelay: Double

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private var isInked: Bool { look != .empty }

    var body: some View {
        GeometryReader { proxy in
            Rectangle()
                .fill(look == .completing ? SbuTheme.inkMuted : SbuTheme.ink)
                .opacity(look == .shadow ? 0.18 : isInked ? 1 : 0)
                .scaleEffect(isInked || reduceMotion ? 1 : 0.3)
                .padding(proxy.size.width * 0.08)
        }
        // A piece appears where it was dropped, at once; emptied cells fade, one after the other.
        .animation(isInked || reduceMotion ? nil : SbuMotion.short.delay(clearDelay), value: isInked)
    }
}

#Preview("Light") {
    HStack(spacing: 0) {
        ForEach([CellLook.empty, .filled, .shadow, .completing], id: \.self) { look in
            BoardCellView(look: look, clearDelay: 0).frame(width: 44, height: 44).border(SbuTheme.line)
        }
    }
}

#Preview("Dark") {
    HStack(spacing: 0) {
        ForEach([CellLook.empty, .filled, .shadow, .completing], id: \.self) { look in
            BoardCellView(look: look, clearDelay: 0).frame(width: 44, height: 44).border(SbuTheme.line)
        }
    }
    .preferredColorScheme(.dark)
}
