import SbuKit
import SwiftUI

/// The pad under the sounds: rings and a cross in `line`, front and back, the listener in the
/// middle with L and R.
struct MixPadGrid: View {
    let radius: CGFloat

    var body: some View {
        ZStack {
            ForEach([1.0, 2.0 / 3.0, 1.0 / 3.0], id: \.self) { scale in
                Circle()
                    .stroke(SbuTheme.line, lineWidth: SbuTheme.hairline)
                    .frame(width: 2 * radius * scale, height: 2 * radius * scale)
            }
            Rectangle().fill(SbuTheme.line).frame(width: SbuTheme.hairline, height: 2 * radius)
            Rectangle().fill(SbuTheme.line).frame(width: 2 * radius, height: SbuTheme.hairline)
            Text("Davanti")
                .font(.caption2)
                .foregroundStyle(SbuTheme.inkMuted)
                .offset(y: -radius - SbuTheme.space3)
            Text("Dietro")
                .font(.caption2)
                .foregroundStyle(SbuTheme.inkMuted)
                .offset(y: radius + SbuTheme.space3)
            HStack(spacing: SbuTheme.space1) {
                Text(verbatim: "L").font(.caption.bold())
                Image(systemName: "headphones").font(.title2.weight(.medium))
                Text(verbatim: "R").font(.caption.bold())
            }
            .foregroundStyle(SbuTheme.ink)
        }
        .accessibilityHidden(true)
    }
}

#Preview("Light") {
    MixPadGrid(radius: 160)
}

#Preview("Dark") {
    MixPadGrid(radius: 160)
        .preferredColorScheme(.dark)
}
