import SbuKit
import SwiftUI

/// The due words of a chore, in `danger` when late and `warning` when due today: the color only
/// repeats what the words say.
struct DueText: View {
    let label: DueLabel

    var body: some View {
        Text(label.text)
            .foregroundStyle(color)
    }

    private var color: Color {
        switch label {
        case .late: SbuTheme.danger
        case .today: SbuTheme.warning
        case .tomorrow, .inDays, .paused: SbuTheme.inkMuted
        }
    }
}

#Preview("Light") {
    DueTextPreview()
}

#Preview("Dark") {
    DueTextPreview()
        .preferredColorScheme(.dark)
}

private struct DueTextPreview: View {
    var body: some View {
        VStack(alignment: .leading, spacing: SbuTheme.space2) {
            DueText(label: .late(days: 6))
            DueText(label: .today)
            DueText(label: .tomorrow)
            DueText(label: .inDays(7))
            DueText(label: .paused)
        }
        .font(SbuTheme.subheadline)
        .padding(SbuTheme.space4)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(SbuTheme.surface)
    }
}
