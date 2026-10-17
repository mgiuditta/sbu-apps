import SbuKit
import SwiftUI

/// "Fatta il…": the day you did it, today or before, never after.
struct DoneOnSheet: View {
    let markDone: (Date) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var day = Date.now

    var body: some View {
        NavigationStack {
            Form {
                DatePicker("Giorno", selection: $day, in: ...Date.now, displayedComponents: .date)
                    .datePickerStyle(.graphical)
                    .listRowBackground(SbuTheme.surfaceRaised)
            }
            .scrollContentBackground(.hidden)
            .background(SbuTheme.paper)
            .navigationTitle("Fatta il…")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annulla", action: cancel)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Segna", action: confirm)
                        .accessibilityIdentifier("confirmDoneOn")
                }
            }
        }
        .presentationDetents([.medium, .large])
    }

    private func cancel() {
        dismiss()
    }

    private func confirm() {
        dismiss()
        markDone(day)
    }
}

#Preview("Light") {
    DoneOnSheet { _ in }
        .environment(\.sbuAccent, .tidy)
}

#Preview("Dark") {
    DoneOnSheet { _ in }
        .environment(\.sbuAccent, .tidy)
        .preferredColorScheme(.dark)
}
