import SbuKit
import SwiftUI

/// Impostazioni: the hour the day starts, for night shifts.
struct StartOfDaySection: View {
    let model: HabitsModel

    @State private var hour: Int

    init(model: HabitsModel) {
        self.model = model
        _hour = State(initialValue: model.startHour)
    }

    var body: some View {
        Section {
            Picker("Inizio della giornata", selection: $hour) {
                ForEach(HabitsFile.startHourRange, id: \.self) { hour in
                    Text(Self.time(at: hour), format: .dateTime.hour().minute())
                        .tag(hour)
                }
            }
        } footer: {
            Text("Quello che fai prima di quest'ora conta per il giorno prima.")
        }
        .onChange(of: hour) { _, hour in
            model.setStartHour(hour)
        }
    }

    /// Today at `hour`:00, only to format the hour for the user's locale.
    private static func time(at hour: Int) -> Date {
        Calendar.current.date(bySettingHour: hour, minute: 0, second: 0, of: .now) ?? .now
    }
}

#Preview("Light") {
    Form {
        StartOfDaySection(model: .preview)
    }
}

#Preview("Dark") {
    Form {
        StartOfDaySection(model: .preview)
    }
    .preferredColorScheme(.dark)
}
