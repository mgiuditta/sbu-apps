import SwiftUI

/// "42 minuti fa", kept current once a second.
///
/// Not the self-updating `Text(_:format: .relative)`: that one grows from "9 secondi" to
/// "12 secondi" without a new layout, and the longer text is clipped.
struct RelativeTimeText: View {
    let date: Date

    var body: some View {
        TimelineView(.periodic(from: .now, by: 1)) { context in
            Text(date.formatted(.relative(presentation: .named)))
                .id(context.date)
        }
    }
}

#Preview("Light") {
    RelativeTimeText(date: .now.addingTimeInterval(-2520))
}

#Preview("Dark") {
    RelativeTimeText(date: .now.addingTimeInterval(-9))
        .preferredColorScheme(.dark)
}
