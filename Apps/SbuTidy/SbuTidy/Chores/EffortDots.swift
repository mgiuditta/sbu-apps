import SbuKit
import SwiftUI

/// Tody's effort: one to three filled ink squares out of three, the size of the row mark; never
/// the accent. VoiceOver reads the word instead.
struct EffortDots: View {
    let effort: Effort

    var body: some View {
        HStack(spacing: SbuTheme.space1) {
            ForEach(Effort.allCases, id: \.self) { level in
                SbuRowMark(filled: level <= effort)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text("Sforzo: \(Text(effort.name))"))
    }
}

#Preview("Light") {
    EffortDotsPreview()
}

#Preview("Dark") {
    EffortDotsPreview()
        .preferredColorScheme(.dark)
}

private struct EffortDotsPreview: View {
    var body: some View {
        VStack(spacing: SbuTheme.space3) {
            ForEach(Effort.allCases, id: \.self) { EffortDots(effort: $0) }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(SbuTheme.paper)
    }
}
