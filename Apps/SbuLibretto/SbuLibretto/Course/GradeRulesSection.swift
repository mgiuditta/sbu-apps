import SbuKit
import SwiftUI

/// Settings → how the average and the base of the degree grade are computed: the value of cum
/// laude, the worst grades left out, the conversion, bonus, multiplier and rounding. No presets by
/// university: the rules change by course and by year, so the examples are in the help.
struct GradeRulesSection: View {
    @Bindable var settings: CourseSettings

    var body: some View {
        Section {
            Picker("Valore della lode", selection: $settings.rules.cumLaudeValue) {
                ForEach([30.0, 31, 32, 33, 34, 35], id: \.self) { value in
                    Text(value, format: .number).tag(value)
                }
            }
            .accessibilityIdentifier("cumLaudeValue")
            Picker("Voti peggiori esclusi", selection: exclusionKind) {
                ForEach(ExclusionKind.allCases) { kind in
                    Text(kind.title).tag(kind)
                }
            }
            .accessibilityIdentifier("exclusionKind")
            switch settings.rules.exclusion {
            case .none:
                EmptyView()
            case .credits:
                RuleNumberField(title: "CFU eliminabili", value: excludedCredits, unit: "CFU", identifier: "excludedCredits")
            case let .exams(count):
                Stepper(value: excludedExams, in: 1...GradeRules.excludedExamsRange.upperBound) {
                    Text("Esami eliminabili: \(count)")
                }
                .accessibilityIdentifier("excludedExams")
            }
        } header: {
            Text("Media")
        } footer: {
            Text("I voti peggiori escono interi, dal più basso, finché restano CFU eliminabili. I CFU restano acquisiti.")
        }
        Section {
            Picker("Conversione", selection: factorChoice) {
                ForEach(FactorChoice.allCases) { choice in
                    Text(choice.title).tag(choice)
                }
            }
            .accessibilityIdentifier("factor")
            if FactorChoice(factor: settings.rules.conversionFactor) == .custom {
                RuleNumberField(title: "Fattore", value: $settings.rules.conversionFactor, identifier: "customFactor")
            }
            RuleNumberField(title: "Moltiplicatore", value: $settings.rules.multiplier, identifier: "multiplier")
            RuleNumberField(title: "Bonus", value: $settings.rules.bonusPoints, unit: "punti", allowsNegative: true, identifier: "bonus")
            Picker("Arrotondamento", selection: $settings.rules.rounding) {
                Text("Nessuno").tag(GradeRounding.none)
                Text("All'intero, 0,50 per eccesso").tag(GradeRounding.nearest)
                Text("Per eccesso").tag(GradeRounding.up)
                Text("Per difetto").tag(GradeRounding.down)
            }
            .accessibilityIdentifier("rounding")
            NavigationLink {
                FormulaHelpView()
            } label: {
                Text("Come calcolano gli atenei")
            }
            .accessibilityIdentifier("formulaHelp")
        } header: {
            Text("Base di laurea")
        } footer: {
            Text(verbatim: settings.rules.formula)
                .accessibilityIdentifier("formula")
        }
    }

    private var exclusionKind: Binding<ExclusionKind> {
        Binding {
            ExclusionKind(settings.rules.exclusion)
        } set: {
            settings.rules.exclusion = $0.exclusion(from: settings.rules.exclusion)
        }
    }

    private var excludedCredits: Binding<Double> {
        Binding {
            if case let .credits(credits) = settings.rules.exclusion { credits } else { 0 }
        } set: {
            settings.rules.exclusion = .credits($0)
        }
    }

    private var excludedExams: Binding<Int> {
        Binding {
            if case let .exams(count) = settings.rules.exclusion { count } else { 1 }
        } set: {
            settings.rules.exclusion = .exams($0)
        }
    }

    private var factorChoice: Binding<FactorChoice> {
        Binding {
            FactorChoice(factor: settings.rules.conversionFactor)
        } set: { choice in
            // Your own factor starts at 3,5, between the two presets, ready to edit.
            settings.rules.conversionFactor = choice.factor ?? 3.5
        }
    }
}

#Preview("Light") {
    NavigationStack {
        List {
            GradeRulesSection(settings: LaunchMode.sample.courseSettings())
        }
    }
}

#Preview("Dark") {
    NavigationStack {
        List {
            GradeRulesSection(settings: LaunchMode.empty.courseSettings())
        }
    }
    .preferredColorScheme(.dark)
}
