import SbuKit
import SwiftUI

/// The due words of a chore, in `ink` when to do today or late and `inkMuted` otherwise: the only
/// color on screen is the full stop's, so the words say it.
struct DueText: View {
    let label: DueLabel

    var body: some View {
        Text(label.text)
            .foregroundStyle(color)
    }

    private var color: Color {
        switch label {
        case .late, .today: SbuTheme.ink
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
        .background(SbuTheme.paper)
    }
}
