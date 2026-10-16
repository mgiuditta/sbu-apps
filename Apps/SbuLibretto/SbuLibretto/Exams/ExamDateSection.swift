import SbuKit
import SwiftUI

/// When the exam was taken, or the planned sitting of one still to take: its date counts down on the dashboard.
struct ExamDateSection: View {
    let isTaken: Bool
    @Binding var date: Date
    @Binding var hasDate: Bool

    var body: some View {
        Section {
            if isTaken {
                DatePicker("Data", selection: $date, in: ...Date.now, displayedComponents: .date)
                    .accessibilityIdentifier("examDate")
            } else {
                Toggle("Data dell'appello", isOn: $hasDate)
                    .accessibilityIdentifier("hasDate")
                if hasDate {
                    DatePicker("Appello", selection: $date, displayedComponents: .date)
                        .accessibilityIdentifier("examDate")
                }
            }
        } footer: {
            if !isTaken {
                Text("Con la data, l'esame compare tra i prossimi appelli con i giorni che mancano.")
            }
        }
    }
}

#Preview("Light") {
    @Previewable @State var date = Date.now
    @Previewable @State var hasDate = true
    Form {
        ExamDateSection(isTaken: false, date: $date, hasDate: $hasDate)
    }
}

#Preview("Dark") {
    @Previewable @State var date = Date.now
    @Previewable @State var hasDate = true
    Form {
        ExamDateSection(isTaken: true, date: $date, hasDate: $hasDate)
    }
    .preferredColorScheme(.dark)
}
