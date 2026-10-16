import SwiftUI

/// The row marker: a 10 pt `ink` square, filled (such as "entro la settimana") or empty with a 1.6
/// border. With the text, the only sign of state in a list row. VoiceOver skips it: the row's text
/// says the state.
public struct SbuRowMark: View {
    private let filled: Bool

    /// Creates the marker.
    /// - Parameter filled: `true` for the filled square, `false` for the outline.
    public init(filled: Bool) {
        self.filled = filled
    }

    public var body: some View {
        Rectangle()
            .fill(filled ? SbuTheme.ink : .clear)
            .overlay {
                if !filled {
                    Rectangle().strokeBorder(SbuTheme.ink, lineWidth: SbuTheme.rowMarkStroke)
                }
            }
            .frame(width: SbuTheme.rowMark, height: SbuTheme.rowMark)
            .accessibilityHidden(true)
    }
}

#Preview("Light") {
    HStack(spacing: SbuTheme.space4) {
        SbuRowMark(filled: true)
        SbuRowMark(filled: false)
    }
    .padding()
}

#Preview("Dark") {
    HStack(spacing: SbuTheme.space4) {
        SbuRowMark(filled: true)
        SbuRowMark(filled: false)
    }
    .padding()
    .preferredColorScheme(.dark)
}
