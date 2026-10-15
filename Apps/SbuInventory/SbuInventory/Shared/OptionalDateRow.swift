import SbuKit
import SwiftUI

/// A date that may be missing: a switch to have one, then the date.
struct OptionalDateRow: View {
    let title: String
    @Binding var date: Date?

    var body: some View {
        Toggle(title, isOn: hasDate)
        if let current = date {
            DatePicker(title, selection: Binding { current } set: { date = $0 }, displayedComponents: .date)
                .labelsHidden()
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var hasDate: Binding<Bool> {
        Binding { date != nil } set: { date = $0 ? (date ?? Calendar.current.startOfDay(for: .now).addingTimeInterval(12 * 3600)) : nil }
    }
}

#Preview("Light") {
    @Previewable @State var date: Date? = .now
    Form {
        OptionalDateRow(title: "Garanzia fino al", date: $date)
    }
}

#Preview("Dark") {
    @Previewable @State var date: Date?
    Form {
        OptionalDateRow(title: "Garanzia fino al", date: $date)
    }
    .preferredColorScheme(.dark)
}
