import SbuKit
import SwiftUI

/// The tool screen: how lit the moon is as the figure, its phase, the moon drawn as it looks, the next four
/// phases, its age and distance, and the date shown.
struct MainView: View {
    let model: MoonModel

    @State private var isPickingDate = false

    var body: some View {
        // Following now, the figure moves with the clock; a picked date stays still.
        TimelineView(.everyMinute) { context in
            let reading = MoonReading(date: model.date(now: context.date), calendar: .current)

            SbuToolField(
                "Illuminazione",
                value: reading.illumination,
                format: .percent.precision(.fractionLength(0)),
                context: reading.phase.name
            ) {
                VStack(spacing: SbuTheme.space6) {
                    MoonDiscView(disc: reading.disc)
                    NextPhasesView(phases: reading.upcomingPhases)
                    MoonDetailsView(age: reading.age, distance: reading.distance)
                }
            } pills: {
                DatePill(date: reading.date, isToday: model.isShowingToday) {
                    isPickingDate = true
                }

                if model.isShowingToday == false {
                    Button("Oggi", action: model.showToday)
                        .buttonStyle(SbuFieldPillStyle())
                        .accessibilityIdentifier("today")
                }
            }
        }
        .sheet(isPresented: $isPickingDate) {
            DatePickerSheet(model: model)
        }
    }
}

#Preview("Light") {
    MainView(model: MoonModel())
        .background(SbuTheme.surface)
        .tint(SbuTheme.accentMoon)
}

#Preview("Dark") {
    MainView(model: MoonModel())
        .background(SbuTheme.surface)
        .tint(SbuTheme.accentMoon)
        .preferredColorScheme(.dark)
}
