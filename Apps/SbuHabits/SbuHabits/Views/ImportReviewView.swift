import SbuKit
import SwiftUI

/// What a file chosen with Importa contains, and the destructive confirmation that replaces the
/// current data with it.
struct ImportReviewView: View {
    @Environment(\.dismiss) private var dismiss

    let model: HabitsModel
    let candidate: HabitsImport

    @State private var failure: HabitsImport.Failure?

    var body: some View {
        NavigationStack {
            Form {
                Section("Nel file") {
                    LabeledContent("Abitudini", value: candidate.file.habits.count, format: .number)

                    if let firstDay = candidate.firstDay {
                        LabeledContent("Primo giorno") {
                            Text(firstDay.noon(in: .current), format: .dateTime.day().month(.wide).year())
                        }
                    }
                }

                if candidate.file.habits.isEmpty == false {
                    Section {
                        ForEach(candidate.file.habits) { habit in
                            Label(habit.title, systemImage: habit.symbol)
                                .foregroundStyle(SbuTheme.ink)
                        }
                    }
                }

                Section {
                    SbuButton("Sostituisci i dati attuali", kind: .destructive, action: replace)
                } footer: {
                    Text("Le abitudini e lo storico su questo iPhone lasciano il posto a quelli del file.")
                }
                .listRowInsets(EdgeInsets())
                .listRowBackground(Color.clear)
            }
            .navigationTitle("Importa")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annulla", action: cancel)
                }
            }
            .importFailureAlert($failure)
        }
        .tint(SbuTheme.accentHabits)
    }

    private func replace() {
        do {
            try model.replace(with: candidate.file)
            dismiss()
        } catch {
            failure = .notSaved
        }
    }

    private func cancel() {
        dismiss()
    }
}

#Preview("Light") {
    ImportReviewView(model: .preview, candidate: .preview)
}

#Preview("Dark") {
    ImportReviewView(model: .preview, candidate: .preview)
        .preferredColorScheme(.dark)
}
