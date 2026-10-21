import SwiftUI

/// The sleep hours, when the Shield covers the native apps by itself.
struct SleepView: View {
    var body: some View {
        TabScreen(title: "Sonno", sentence: "Scegli quando dormi: i social si chiudono da soli.")
    }
}

#Preview("Light") {
    SleepView()
}

#Preview("Dark") {
    SleepView()
        .preferredColorScheme(.dark)
}
