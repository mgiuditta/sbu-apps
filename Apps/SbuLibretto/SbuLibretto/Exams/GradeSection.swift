import SbuKit
import SwiftUI

/// The grade of a taken exam: a mark from 18 to 30, and cum laude when it is 30.
struct GradeSection: View {
    @Binding var mark: Int
    @Binding var cumLaude: Bool

    var body: some View {
        Section {
            Picker("Voto", selection: $mark) {
                ForEach((Grade.lowest...Grade.highest).reversed(), id: \.self) { mark in
                    Text(mark, format: .number).tag(mark)
                }
            }
            .pickerStyle(.menu)
            .accessibilityIdentifier("grade")
            if mark == Grade.highest {
                Toggle("Lode", isOn: $cumLaude)
                    .accessibilityIdentifier("cumLaude")
            }
        } footer: {
            Text("Quanto vale la lode nella media lo scegli in Impostazioni.")
        }
    }
}

#Preview("Light") {
    @Previewable @State var mark = 30
    @Previewable @State var cumLaude = true
    Form {
        GradeSection(mark: $mark, cumLaude: $cumLaude)
    }
}

#Preview("Dark") {
    @Previewable @State var mark = 27
    @Previewable @State var cumLaude = false
    Form {
        GradeSection(mark: $mark, cumLaude: $cumLaude)
    }
    .preferredColorScheme(.dark)
}
