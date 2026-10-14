import SwiftUI

/// A pill's title and symbol; only the symbol at the accessibility text sizes, so three pills still fit.
struct PillLabel: View {
    let title: LocalizedStringKey
    let systemImage: String
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        Label(title, systemImage: systemImage)
            .labelStyle(dynamicTypeSize.isAccessibilitySize ? AnyLabelStyle(.iconOnly) : AnyLabelStyle(.titleAndIcon))
            .fontWeight(.medium)
    }
}

#Preview("Light") {
    PillLabel(title: "Torcia", systemImage: "flashlight.on.fill")
}

#Preview("Dark") {
    PillLabel(title: "Torcia", systemImage: "flashlight.on.fill")
        .preferredColorScheme(.dark)
}
