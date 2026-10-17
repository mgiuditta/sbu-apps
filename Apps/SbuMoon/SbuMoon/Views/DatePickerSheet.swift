import SbuKit
import SwiftUI

/// A calendar to pick the day to show; the screen behind follows each tap.
struct DatePickerSheet: View {
    let model: MoonModel

    @State private var date: Date
    @Environment(\.dismiss) private var dismiss

    init(model: MoonModel) {
        self.model = model
        _date = State(initialValue: model.date(now: .now))
    }

    var body: some View {
        NavigationStack {
            Form {
                DatePicker("Data", selection: $date, in: MoonModel.dateRange, displayedComponents: .date)
                    .datePickerStyle(.graphical)
                    .listRowBackground(SbuTheme.surfaceRaised)
            }
            .scrollContentBackground(.hidden)
            .background(SbuTheme.paper)
            .navigationTitle("Data")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Oggi", action: showToday)
                        .disabled(Calendar.current.isDateInToday(date))
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Fine") { dismiss() }
                }
            }
        }
        .onChange(of: date) {
            model.show(date)
        }
    }

    private func showToday() {
        model.showToday()
        dismiss()
    }
}

#Preview("Light") {
    DatePickerSheet(model: MoonModel())
        .tint(SbuTheme.ink)
}

#Preview("Dark") {
    DatePickerSheet(model: MoonModel())
        .tint(SbuTheme.ink)
        .preferredColorScheme(.dark)
}
