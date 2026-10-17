import SbuKit
import SwiftUI

/// One row of a card under the moon: a label on the left, its value on the right in `inkMuted`,
/// read as one element. When they don't fit on one line, as at accessibility text sizes, the value
/// goes under the label.
struct MoonFactRow: View {
    private let label: LocalizedStringKey
    private let value: Text

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    init(_ label: LocalizedStringKey, value: Text) {
        self.label = label
        self.value = value
    }

    init(_ fact: MoonFact) {
        self.init(fact.label, value: fact.value)
    }

    var body: some View {
        Group {
            if dynamicTypeSize.isAccessibilitySize {
                stacked
            } else {
                // Side by side while both fit on one line each; never a value broken over two lines.
                ViewThatFits(in: .horizontal) {
                    sideBySide
                    stacked
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .combine)
    }

    private var labelText: some View {
        Text(label)
            .font(SbuTheme.body)
            .foregroundStyle(SbuTheme.ink)
    }

    private var valueText: some View {
        value
            .font(SbuTheme.body)
            .monospacedDigit()
            .foregroundStyle(SbuTheme.inkMuted)
    }

    private var sideBySide: some View {
        HStack(alignment: .firstTextBaseline, spacing: SbuTheme.space4) {
            labelText
                .fixedSize()
            Spacer(minLength: 0)
            valueText
                .fixedSize()
        }
    }

    private var stacked: some View {
        VStack(alignment: .leading, spacing: SbuTheme.space1) {
            labelText
            valueText
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview("Light") {
    MoonFactRowPreview()
}

#Preview("Dark") {
    MoonFactRowPreview()
        .preferredColorScheme(.dark)
}

#Preview("Accessibility size") {
    MoonFactRowPreview()
        .dynamicTypeSize(.accessibility3)
}

private struct MoonFactRowPreview: View {
    private let facts = [
        MoonFact(id: "full", label: "Luna piena", value: Text(Date.now, format: .dateTime.weekday().day().month().hour().minute())),
        MoonFact(id: "distance", label: "Distanza dalla Terra", value: Text(Measurement(value: 384_400, unit: UnitLength.kilometers), format: .measurement(width: .abbreviated))),
    ]

    var body: some View {
        SbuListCard(facts) { fact in
            MoonFactRow(fact)
        }
        .padding(SbuTheme.space4)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .sbuPaper(grid: true)
    }
}
