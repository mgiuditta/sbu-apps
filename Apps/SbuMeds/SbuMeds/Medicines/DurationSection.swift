import SbuKit
import SwiftUI

/// From when, and until when if it is a course: an antibiotic for a week, a syrup for five days.
struct DurationSection: View {
    @Binding var draft: MedicineDraft

    @Environment(\.calendar) private var calendar

    var body: some View {
        Section("Durata") {
            DatePicker("Inizio", selection: day(\.start), displayedComponents: .date)
            Toggle("Fino a una data", isOn: $draft.hasEnd)
                .accessibilityIdentifier("hasEnd")
            if draft.hasEnd {
                DatePicker("Ultimo giorno", selection: day(\.end), in: draft.start.start(in: calendar)..., displayedComponents: .date)
            }
        }
    }

    private func day(_ keyPath: WritableKeyPath<MedicineDraft, Day>) -> Binding<Date> {
        Binding {
            draft[keyPath: keyPath].start(in: calendar)
        } set: { date in
            draft[keyPath: keyPath] = Day(date, calendar: calendar)
        }
    }
}

#Preview("Light") {
    DurationSectionPreview()
}

#Preview("Dark") {
    DurationSectionPreview()
        .preferredColorScheme(.dark)
}

private struct DurationSectionPreview: View {
    @State private var draft: MedicineDraft = {
        var draft = MedicineDraft(today: Day(.now, calendar: .current), calendar: .current)
        draft.hasEnd = true
        return draft
    }()

    var body: some View {
        Form {
            DurationSection(draft: $draft)
        }
        .environment(\.sbuAccent, .meds)
    }
}
