import SbuKit
import SwiftUI

/// The app inside the standard Sbu shell.
struct RootView: View {
    let settings: CourseSettings

    var body: some View {
        SbuAppShell("Sbu Libretto", slug: "libretto", accent: .libretto, appIcon: Image(.appIconArtwork)) {
            MainView(settings: settings)
        } settings: {
            CourseSection(settings: settings)
            GradeRulesSection(settings: settings)
        }
    }
}

#Preview("Light") {
    RootView(settings: LaunchMode.sample.courseSettings())
        .modelContainer(.preview)
}

#Preview("Dark") {
    RootView(settings: LaunchMode.sample.courseSettings())
        .modelContainer(.preview)
        .preferredColorScheme(.dark)
}
