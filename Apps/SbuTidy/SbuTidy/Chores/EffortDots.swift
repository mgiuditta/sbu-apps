import SbuKit
import SwiftUI

/// Tody's effort: one to three filled dots out of three. VoiceOver reads the word instead.
struct EffortDots: View {
    let effort: Effort

    var body: some View {
        HStack(spacing: SbuTheme.space1) {
            ForEach(Effort.allCases, id: \.self) { level in
                Image(systemName: level <= effort ? "circle.fill" : "circle")
            }
        }
        .font(SbuTheme.caption)
        .fontWeight(.medium)
        .imageScale(.small)
        .foregroundStyle(SbuTheme.inkMuted)
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
        .background(SbuTheme.surface)
    }
}
