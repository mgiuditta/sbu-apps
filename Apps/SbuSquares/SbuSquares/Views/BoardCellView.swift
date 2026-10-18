import SbuKit
import SwiftUI

/// One square of the board: a colored square inset in its cell, or nothing.
struct BoardCellView: View {
    let look: CellLook
    /// How long an emptied cell waits before fading, so a completed line clears as a wave.
    let clearDelay: Double

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private var isInked: Bool { look != .empty }

    private var color: Color {
        switch look {
        case .empty: .clear
        case .filled(let color), .shadow(let color), .completing(let color): color
        }
    }

    private var isShadow: Bool {
        if case .shadow = look { true } else { false }
    }

    var body: some View {
        GeometryReader { proxy in
            Rectangle()
                .fill(color)
                .opacity(isShadow ? 0.3 : isInked ? 1 : 0)
                .scaleEffect(isInked || reduceMotion ? 1 : 0.3)
                .padding(proxy.size.width * 0.08)
        }
        // A piece appears where it was dropped, at once; emptied cells fade, one after the other.
        .animation(isInked || reduceMotion ? nil : SbuMotion.short.delay(clearDelay), value: isInked)
    }
}

#Preview("Light") {
    HStack(spacing: 0) {
        ForEach([CellLook.empty, .filled(PieceTone.color(0)), .shadow(PieceTone.color(1)), .completing(PieceTone.color(1))], id: \.self) { look in
            BoardCellView(look: look, clearDelay: 0).frame(width: 44, height: 44).border(SbuTheme.line)
        }
    }
}

#Preview("Dark") {
    HStack(spacing: 0) {
        ForEach([CellLook.empty, .filled(PieceTone.color(2)), .shadow(PieceTone.color(3)), .completing(PieceTone.color(3))], id: \.self) { look in
            BoardCellView(look: look, clearDelay: 0).frame(width: 44, height: 44).border(SbuTheme.line)
        }
    }
    .preferredColorScheme(.dark)
}
