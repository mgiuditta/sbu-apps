import SbuKit
import SwiftUI

/// A sitting with its countdown: the exam and its date on the left, the days left on the right.
struct SittingRow: View {
    let sitting: ExamCountdown.Sitting

    @ScaledMetric(relativeTo: .title2) private var daysSize = SbuTheme.statSmallSize

    var body: some View {
        LabeledContent {
            Text(verbatim: sitting.day.text)
                .font(SbuTheme.smallNumberFont(size: daysSize))
                .foregroundStyle(sitting.day.isPast ? SbuTheme.inkMuted : SbuTheme.ink)
                .multilineTextAlignment(.trailing)
        } label: {
            VStack(alignment: .leading, spacing: 0) {
                Text(sitting.name)
                    .font(SbuTheme.headline)
                    .foregroundStyle(SbuTheme.ink)
                Text(verbatim: subtitle)
                    .font(SbuTheme.subheadline)
                    .foregroundStyle(SbuTheme.inkMuted)
            }
        }
        .padding(.vertical, SbuTheme.space1)
        .contentShape(.rect)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(sitting.name))
        .accessibilityValue(Text(verbatim: "\(sitting.day.text), \(subtitle)"))
    }

    private var subtitle: String {
        let date = sitting.date.formatted(.dateTime.weekday(.abbreviated).day().month(.abbreviated))
        return String(localized: "\(sitting.credits.formatted(LibrettoFormat.credits)) CFU") + " · " + date
    }
}

#Preview("Light") {
    List {
        SittingRow(sitting: .init(id: UUID(), name: "Sistemi operativi", credits: 9, date: .now.addingTimeInterval(86_400 * 12), day: .inDays(12)))
        SittingRow(sitting: .init(id: UUID(), name: "Reti", credits: 6, date: .now, day: .today))
    }
}

#Preview("Dark") {
    List {
        SittingRow(sitting: .init(id: UUID(), name: "Fisica II", credits: 6, date: .now.addingTimeInterval(-86_400 * 3), day: .daysAgo(3)))
    }
    .preferredColorScheme(.dark)
}
