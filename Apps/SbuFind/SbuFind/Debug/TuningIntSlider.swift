#if DEBUG
import SwiftUI

/// A whole-number threshold on the Taratura screen, as a slider in steps of one.
struct TuningIntSlider: View {
    let title: String
    @Binding var value: Int
    let range: ClosedRange<Int>

    var body: some View {
        TuningSlider(
            title: title,
            value: Binding(get: { Double(value) }, set: { value = Int($0.rounded()) }),
            range: Double(range.lowerBound)...Double(range.upperBound),
            step: 1
        )
    }
}

#Preview("Light") {
    @Previewable @State var value = 35
    Form {
        TuningIntSlider(title: "Tiepido da (%)", value: $value, range: 5...90)
    }
}

#Preview("Dark") {
    @Previewable @State var value = 80
    Form {
        TuningIntSlider(title: "Qui vicino da (%)", value: $value, range: 15...100)
    }
    .preferredColorScheme(.dark)
}
#endif
