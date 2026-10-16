import SwiftUI

/// The Closure: for two seconds the figure gives way to one word and the full stop, in an ink block.
///
/// The block is `ink` with `radiusClosure`, the word Bricolage in `paper`, the full stop in the
/// accent's `onInk`. It is the only dark surface besides Sbu Speed's Parabrezza: never at launch,
/// at most once per event. VoiceOver announces the word; the `closure` haptic plays.
struct SbuClosure: ViewModifier {
    @Binding var isPresented: Bool
    let word: LocalizedStringResource

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func body(content: Content) -> some View {
        content
            .opacity(isPresented ? 0 : 1)
            .overlay {
                if isPresented {
                    block
                        .transition(.opacity)
                }
            }
            .animation(SbuMotion.animation(SbuMotion.short, reduceMotion: reduceMotion), value: isPresented)
            .sensoryFeedback(SbuHaptic.closure.feedback, trigger: isPresented) { _, new in new }
            .task(id: isPresented) {
                guard isPresented else { return }
                AccessibilityNotification.Announcement(String(localized: word)).post()
                try? await Task.sleep(for: .seconds(SbuTheme.closureDuration))
                guard !Task.isCancelled else { return }
                isPresented = false
            }
    }

    private var block: some View {
        HStack(alignment: .lastTextBaseline, spacing: 0) {
            Text(word)
                .font(.sbuFigure(size: SbuTheme.figureWidget, width: SbuTheme.figureWidthMid))
                .foregroundStyle(SbuTheme.paper)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
            SbuFullStop(onInk: .inline)
        }
        .padding(SbuTheme.space6)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
        .background(SbuTheme.ink, in: .rect(cornerRadius: SbuTheme.radiusClosure))
        .accessibilityElement(children: .combine)
    }
}

public extension View {
    /// Shows the Closure over this view (the figure zone) while `isPresented` is `true`, and sets it
    /// back to `false` after `closureDuration`.
    /// - Parameters:
    ///   - isPresented: Set to `true` once per completion event.
    ///   - word: One participle with its full stop drawn for it: "Fatto", "Pagato", "In bolla".
    func sbuClosure(_ isPresented: Binding<Bool>, word: LocalizedStringResource) -> some View {
        modifier(SbuClosure(isPresented: isPresented, word: word))
    }

    /// Marks a control that changes the figure: each change of `value` plays the `tick` haptic and
    /// makes the full stop beat.
    func sbuAffectsFigure(_ value: some Equatable) -> some View {
        modifier(SbuAffectsFigure(value: value))
    }
}

private struct SbuAffectsFigure<Value: Equatable>: ViewModifier {
    let value: Value

    @Environment(\.sbuFigurePulse) private var pulse

    func body(content: Content) -> some View {
        content
            .onChange(of: value) {
                pulse?.count += 1
            }
            .sbuHaptic(.tick, trigger: value)
    }
}

#Preview("Light") {
    SbuClosurePreview()
}

#Preview("Dark") {
    SbuClosurePreview()
        .preferredColorScheme(.dark)
}

private struct SbuClosurePreview: View {
    @State private var isClosing = false

    var body: some View {
        VStack(alignment: .leading, spacing: SbuTheme.space6) {
            SbuFigure(value: "3", context: Text(verbatim: "di 3 oggi"))
                .sbuClosure($isClosing, word: "Fatto")
            Button("Chiudi") { isClosing = true }
        }
        .padding(SbuTheme.space4)
        .frame(maxHeight: .infinity, alignment: .top)
        .sbuPaper()
        .environment(\.sbuAccent, .habits)
    }
}
