import SwiftUI

/// The empty state and first run: the figure "0" with a waiting full stop, one sentence in the
/// second person, one native button. No illustration, no carousel, no permission asked in advance.
///
/// Put it on a paper area (`.sbuPaper(grid: true)`).
public struct SbuEmpty<Action: View>: View {
    private let sentence: Text
    private let action: Action

    /// Creates the empty state.
    /// - Parameters:
    ///   - sentence: What to do first, in the second person: "Aggiungi la tua prima abitudine."
    ///   - action: One native button, such as `Button("Aggiungi", action: add)`.
    public init(sentence: LocalizedStringKey, @ViewBuilder action: () -> Action) {
        self.sentence = Text(sentence)
        self.action = action()
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: SbuTheme.space6) {
            SbuFigure(value: 0.formatted(), fullStop: .waiting, accessibilityLabel: sentence)
                .accessibilityHidden(true)
            sentence
                .font(SbuTheme.body)
                .foregroundStyle(SbuTheme.ink)
                .fixedSize(horizontal: false, vertical: true)
            action
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

public extension SbuEmpty where Action == EmptyView {
    /// Creates an empty state with no button, when the screen already has the one way forward.
    init(sentence: LocalizedStringKey) {
        self.init(sentence: sentence) { EmptyView() }
    }
}

#Preview("Light") {
    SbuEmptyPreview()
}

#Preview("Dark") {
    SbuEmptyPreview()
        .preferredColorScheme(.dark)
}

#Preview("AX5") {
    SbuEmptyPreview()
        .dynamicTypeSize(.accessibility5)
}

private struct SbuEmptyPreview: View {
    var body: some View {
        SbuEmpty(sentence: "Aggiungi la tua prima abitudine.") {
            Button("Aggiungi") {}
        }
        .padding(SbuTheme.space4)
        .frame(maxHeight: .infinity, alignment: .top)
        .sbuPaper()
        .tint(SbuTheme.ink)
    }
}
