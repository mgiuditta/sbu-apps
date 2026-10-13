import SbuKit
import SwiftUI

/// The form's Titolo: blank means automatic, with the characters used out of the most a
/// title can have.
struct HabitTitleSection: View {
    @Binding var title: String

    var body: some View {
        Section {
            TextField("Titolo", text: $title, prompt: Text("Automatico"))
                // With a prompt, a form's field drops its title from VoiceOver.
                .accessibilityLabel("Titolo")
                .onChange(of: title, limit)
        } header: {
            Text("Titolo")
        } footer: {
            Text(verbatim: "\(title.count.formatted())/\(Habit.maxTitleLength.formatted())")
                .monospacedDigit()
                .frame(maxWidth: .infinity, alignment: .trailing)
                .accessibilityLabel("Caratteri")
                .accessibilityValue(Text("\(title.count) di \(Habit.maxTitleLength)"))
        }
    }

    private func limit() {
        if title.count > Habit.maxTitleLength {
            title = String(title.prefix(Habit.maxTitleLength))
        }
    }
}

#Preview("Light") {
    HabitTitleSectionPreview()
}

#Preview("Dark") {
    HabitTitleSectionPreview()
        .preferredColorScheme(.dark)
}

private struct HabitTitleSectionPreview: View {
    @State private var title = ""

    var body: some View {
        Form {
            HabitTitleSection(title: $title)
        }
        .tint(SbuTheme.accentHabits)
    }
}
