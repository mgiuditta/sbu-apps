import SbuKit
import SwiftUI

/// The average you aim at, and the grade the next exam needs for it.
struct TargetSection: View {
    let simulation: Simulation
    @Binding var targetText: String

    @Environment(\.locale) private var locale
    @FocusState private var isEditing: Bool

    var body: some View {
        Section {
            NumberField(title: "Media obiettivo", text: $targetText, prompt: "28", identifier: "targetAverage", focus: $isEditing)
                .toolbar {
                    ToolbarItemGroup(placement: .keyboard) {
                        Spacer()
                        // The decimal keypad has no return key.
                        Button("Fine", action: endEditing)
                    }
                }
            Text(answer)
                .font(SbuTheme.subheadline)
                .foregroundStyle(SbuTheme.inkMuted)
                .accessibilityIdentifier("requiredGrade")
        } header: {
            Text("Obiettivo")
        }
    }

    private func endEditing() {
        isEditing = false
    }

    private var answer: LocalizedStringKey {
        guard !targetText.trimmingCharacters(in: .whitespaces).isEmpty else {
            return "Scrivi la media che vuoi raggiungere: ti dico il voto che serve al prossimo esame."
        }
        guard let target = NumberText.double(targetText, locale: locale), let required = simulation.requiredGrade(forAverage: target) else {
            return "Scrivi la media come numero, per esempio 27,5."
        }
        let credits = simulation.credits.formatted(LibrettoFormat.credits)
        switch required {
        case .anyGrade:
            return "Con qualsiasi voto resti a \(target.formatted(LibrettoFormat.average)) o più."
        case .atLeast(.cumLaude):
            return "Ti serve 30 e lode nell'esame da \(credits) CFU."
        case let .atLeast(grade):
            return "Ti serve almeno \(grade.mark) nell'esame da \(credits) CFU."
        case .unreachable:
            return "Con un solo esame da \(credits) CFU non ci arrivi, neanche con 30 e lode."
        }
    }
}

#Preview("Light") {
    @Previewable @State var target = "28,5"
    List {
        TargetSection(simulation: Simulation([ExamRecord(credits: 12, result: .graded(.mark(28)), date: nil)], rules: .standard, credits: 12),
                      targetText: $target)
    }
}

#Preview("Dark") {
    @Previewable @State var target = ""
    List {
        TargetSection(simulation: Simulation([], rules: .standard, credits: 6), targetText: $target)
    }
    .preferredColorScheme(.dark)
}
