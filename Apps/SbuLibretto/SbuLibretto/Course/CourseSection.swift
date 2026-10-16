import SbuKit
import SwiftUI

/// Settings → the course, as the original's Università page: names optional, no list of universities to pick from.
struct CourseSection: View {
    @Bindable var settings: CourseSettings

    var body: some View {
        Section {
            // Bare fields, the name in the prompt: beside a label, a long course name was cut.
            TextField("Ateneo", text: $settings.university, prompt: Text("Ateneo, facoltativo"))
                .accessibilityIdentifier("university")
            TextField("Corso di laurea", text: $settings.course, prompt: Text("Corso di laurea, facoltativo"))
                .accessibilityIdentifier("courseName")
            RuleNumberField(title: "CFU totali", value: $settings.rules.totalCredits, unit: "CFU", identifier: "totalCredits")
        } header: {
            Text("Corso")
        } footer: {
            Text("180 CFU per una triennale, 120 per una magistrale, 300 o 360 a ciclo unico.")
        }
    }
}

#Preview("Light") {
    List {
        CourseSection(settings: LaunchMode.sample.courseSettings())
    }
}

#Preview("Dark") {
    List {
        CourseSection(settings: LaunchMode.empty.courseSettings())
    }
    .preferredColorScheme(.dark)
}
