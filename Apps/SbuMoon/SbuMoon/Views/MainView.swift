import SbuKit
import SwiftUI

/// The tool screen: how lit the moon is as the figure, its phase, the moon drawn as it looks,
/// the next four phases, its age and distance, and the date shown. Swipe to change day.
struct MainView: View {
    let model: MoonModel

    @State private var isPickingDate = false

    var body: some View {
        // Following now, the figure moves with the clock; a picked date stays still.
        TimelineView(.everyMinute) { context in
            let reading = MoonReading(date: model.date(now: context.date), calendar: .current)

            // Scrolls only when large text makes the screen taller than the display.
            GeometryReader { proxy in
                ScrollView {
                    toolField(for: reading)
                        .frame(minHeight: proxy.size.height)
                }
                .scrollBounceBehavior(.basedOnSize)
            }
        }
        .contentShape(.rect)
        .simultaneousGesture(DragGesture(minimumDistance: SbuTheme.space6).onEnded(swipe))
        .sheet(isPresented: $isPickingDate) {
            DatePickerSheet(model: model)
        }
    }

    private func toolField(for reading: MoonReading) -> some View {
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
            .accessibilityAction(named: "Giorno precedente", showPreviousDay)
            .accessibilityAction(named: "Giorno successivo", showNextDay)

            if model.isShowingToday == false {
                Button("Oggi", action: model.showToday)
                    .buttonStyle(SbuFieldPillStyle())
                    .accessibilityIdentifier("today")
            }
        }
    }

    /// A horizontal swipe turns the day: to the left the next one, to the right the previous one.
    private func swipe(_ value: DragGesture.Value) {
        let horizontal = value.translation.width
        guard abs(horizontal) > abs(value.translation.height), abs(horizontal) >= SbuTheme.space12 else { return }
        if horizontal < 0 {
            showNextDay()
        } else {
            showPreviousDay()
        }
    }

    private func showPreviousDay() {
        model.showDay(byAdding: -1)
    }

    private func showNextDay() {
        model.showDay(byAdding: 1)
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
