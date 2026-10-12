import SbuKit
import SwiftUI

/// One secondary line under the moon: a label on the left, its value on the right, read as one
/// element. At accessibility text sizes the value goes under the label.
struct MoonFactRow: View {
    private let label: LocalizedStringKey
    private let value: Text

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    init(_ label: LocalizedStringKey, value: Text) {
        self.label = label
        self.value = value
    }

    private var layout: AnyLayout {
        dynamicTypeSize.isAccessibilitySize
            ? AnyLayout(VStackLayout(alignment: .leading, spacing: SbuTheme.space1))
            : AnyLayout(HStackLayout(alignment: .firstTextBaseline, spacing: SbuTheme.space4))
    }

    var body: some View {
        layout {
            Text(label)
                .font(SbuTheme.footnote)

            if dynamicTypeSize.isAccessibilitySize == false {
                Spacer(minLength: 0)
            }

            value
                .font(SbuTheme.subheadline)
                .monospacedDigit()
        }
        .foregroundStyle(SbuTheme.inkMuted)
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .combine)
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
