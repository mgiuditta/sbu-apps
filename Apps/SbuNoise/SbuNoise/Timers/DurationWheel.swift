import SwiftUI

/// Hours and minutes on two wheels, like the system countdown picker.
struct DurationWheel: View {
    @Binding var hours: Int
    @Binding var minutes: Int

    var body: some View {
        HStack(spacing: 0) {
            Picker("Ore", selection: $hours) {
                ForEach(0..<24, id: \.self) { hour in
                    Text(Duration.seconds(hour * 3600), format: .units(allowed: [.hours], width: .wide, zeroValueUnits: .show(length: 1)))
                }
            }
            Picker("Minuti", selection: $minutes) {
                ForEach(0..<60, id: \.self) { minute in
                    Text(Duration.seconds(minute * 60), format: .units(allowed: [.minutes], width: .abbreviated, zeroValueUnits: .show(length: 1)))
                }
            }
        }
        .pickerStyle(.wheel)
    }
}

#Preview("Light") {
    DurationWheel(hours: .constant(1), minutes: .constant(30))
}

#Preview("Dark") {
    DurationWheel(hours: .constant(8), minutes: .constant(0))
        .preferredColorScheme(.dark)
}
