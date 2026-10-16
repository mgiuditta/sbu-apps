import SbuKit
import SwiftUI
import WidgetKit

/// The caption and the weighted average with its full stop: the one figure of the widget.
struct AverageBlock: View {
    let snapshot: WidgetSnapshot?
    let size: CGFloat

    var body: some View {
        VStack(alignment: .leading, spacing: SbuTheme.space1) {
            Text("Media")
                .font(SbuTheme.caption)
                .textCase(.uppercase)
                .tracking(SbuTheme.captionTracking)
                .foregroundStyle(SbuTheme.inkMuted)
            if let average = snapshot?.average {
                HStack(alignment: .firstTextBaseline, spacing: 0) {
                    Text(average, format: LibrettoFormat.average)
                        .font(SbuTheme.numberFont(size: size))
                        .foregroundStyle(SbuTheme.ink)
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                        .widgetAccentable()
                    SbuFullStop(fontSize: size)
                }
                if let snapshot {
                    Text("\(snapshot.earnedCredits.formatted(LibrettoFormat.credits))/\(snapshot.totalCredits.formatted(LibrettoFormat.credits)) CFU")
                        .font(SbuTheme.footnote)
                        .foregroundStyle(SbuTheme.inkMuted)
                        .lineLimit(1)
                }
            } else {
                Text("Registra il primo voto")
                    .font(SbuTheme.footnote)
                    .foregroundStyle(SbuTheme.inkMuted)
            }
        }
    }
}
