import SbuKit
import SwiftUI

/// One secondary line under the moon: a label on the left, its value on the right, read as one
/// element. When they don't fit on one line, as at accessibility text sizes, the value goes under
/// the label.
struct MoonFactRow: View {
    private let label: LocalizedStringKey
    private let value: Text

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    init(_ label: LocalizedStringKey, value: Text) {
        self.label = label
        self.value = value
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
        .foregroundStyle(SbuTheme.inkMuted)
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .combine)
    }

    private var labelText: some View {
        Text(label)
            .font(SbuTheme.footnote)
    }

    private var valueText: some View {
        value
            .font(SbuTheme.subheadline)
            .monospacedDigit()
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
    var body: some View {
        VStack(spacing: SbuTheme.space2) {
            MoonFactRow("Luna piena", value: Text(Date.now, format: .dateTime.weekday().day().month().hour().minute()))
            MoonFactRow("Distanza dalla Terra", value: Text(Measurement(value: 384_400, unit: UnitLength.kilometers), format: .measurement(width: .abbreviated)))
        }
        .padding(SbuTheme.space4)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(SbuTheme.surface)
    }
}
