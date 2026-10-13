import SbuKit
import SwiftUI

/// The tool screen: how lit the moon is as the figure, its phase, the moon drawn as it looks,
/// moonrise and moonset where the user is, the next four phases, its age and distance, and the
/// date shown. Swipe to change day.
struct MainView: View {
    let model: MoonModel
    let places: PlaceModel

    @State private var isPickingDate = false
    @State private var isPickingPlace = false

    /// The name of the place for rise and set, or `nil` before one is chosen.
    private var placeName: Text? {
        guard let place = places.place else { return nil }
        if let city = places.city {
            return Text(verbatim: city.name())
        }
        return place.isCurrentLocation ? Text("La tua posizione") : nil
    }

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
        .sheet(isPresented: $isPickingPlace) {
            PlaceSheet(places: places)
        }
    }

    private func toolField(for reading: MoonReading) -> some View {
        SbuToolField(
            "Illuminazione",
            // The percent sign is the unit, in SF like Level's degree: Bricolage's "%" dips below
            // the baseline and would leave the full stop looking raised.
            value: reading.illumination * 100,
            format: .number.precision(.fractionLength(0)),
            unit: "%",
            context: reading.phase.name
        ) {
            VStack(spacing: SbuTheme.space6) {
                MoonDiscView(disc: reading.disc)
                RiseSetView(riseSet: riseSet(on: reading.date), placeName: placeName) {
                    isPickingPlace = true
                }
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

    /// Rise and set on the day shown, in the iPhone's time zone like every other time on screen.
    private func riseSet(on date: Date) -> MoonRiseSet? {
        guard let place = places.place else { return nil }
        return MoonHorizon.riseSet(on: date, at: place.coordinates, calendar: .current)
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
    MainView(model: MoonModel(), places: PlaceModel())
        .background(SbuTheme.surface)
        .tint(SbuTheme.accentMoon)
}

#Preview("Dark") {
    MainView(model: MoonModel(), places: PlaceModel())
        .background(SbuTheme.surface)
        .tint(SbuTheme.accentMoon)
        .preferredColorScheme(.dark)
}
