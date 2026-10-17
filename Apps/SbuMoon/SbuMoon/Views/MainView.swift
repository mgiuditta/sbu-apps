import SbuKit
import SwiftUI

/// The tool screen: Illuminazione and its cartiglio, how lit the moon is as the figure on the grid,
/// the date pills, the moon drawn as it looks, moonrise and moonset where the user is, the next four
/// phases, its age and distance. Swipe to change day.
struct MainView: View {
    let model: MoonModel
    let places: PlaceModel

    @State private var isPickingDate = false
    @State private var isPickingPlace = false

    /// The name of the place for rise and set, or `nil` before one is chosen.
    private var placeName: String? {
        guard let place = places.place else { return nil }
        if let city = places.city {
            return city.name()
        }
        return place.isCurrentLocation ? String(localized: "La tua posizione") : nil
    }

    var body: some View {
        // Following now, the figure moves with the clock; a picked date stays still.
        TimelineView(.everyMinute) { context in
            let reading = MoonReading(date: model.date(now: context.date), calendar: .current)

            ScrollView {
                content(for: reading)
            }
            .scrollBounceBehavior(.basedOnSize)
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

    private func content(for reading: MoonReading) -> some View {
        VStack(alignment: .leading, spacing: SbuTheme.space6) {
            SbuScreenTitle("Illuminazione", cartiglio: cartiglio(for: reading.date))

            figure(for: reading)

            pills(for: reading)

            MoonDiscView(disc: reading.disc)

            RiseSetView(times: riseSet(on: reading.date), placeName: placeName) {
                isPickingPlace = true
            }
            NextPhasesView(phases: reading.upcomingPhases)
            MoonDetailsView(age: reading.age, distance: reading.distance)
        }
        .padding(.horizontal, SbuTheme.space4)
        .padding(.vertical, SbuTheme.space6)
        .frame(maxWidth: .infinity, alignment: .topLeading)
        // Inside the scroll content, so the grid and the figure's baseline scroll together.
        .sbuPaper(grid: true)
    }

    private func figure(for reading: MoonReading) -> some View {
        let value = (reading.illumination * 100).formatted(.number.precision(.fractionLength(0)))
        // The illumination is worked out, not measured: final as soon as it is there. Only a
        // position being read leaves the screen waiting, since rise and set follow from it.
        // VoiceOver reads the title, Illuminazione, then "63%, Gibbosa crescente".
        return SbuFigure(
            value: value,
            unit: "%",
            fullStop: places.locationState == .locating ? .waiting : .set,
            context: Text(reading.phase.name)
        )
    }

    /// The date pill and, on another day, Oggi: side by side, one under the other at large sizes.
    private func pills(for reading: MoonReading) -> some View {
        ViewThatFits(in: .horizontal) {
            HStack(spacing: SbuTheme.space2) {
                datePills(for: reading)
            }
            VStack(alignment: .leading, spacing: SbuTheme.space2) {
                datePills(for: reading)
            }
        }
    }

    @ViewBuilder private func datePills(for reading: MoonReading) -> some View {
        DatePill(date: reading.date, isToday: model.isShowingToday) {
            isPickingDate = true
        }
        .accessibilityAction(named: "Giorno precedente", showPreviousDay)
        .accessibilityAction(named: "Giorno successivo", showNextDay)
        // Every change of day, from the pill, the calendar, a swipe or Oggi, changes the figure.
        .sbuAffectsFigure(model.pickedDate)

        if model.isShowingToday == false {
            Button("Oggi", action: model.showToday)
                .buttonStyle(SbuFieldPillStyle())
                .accessibilityIdentifier("today")
        }
    }

    /// "Sbu · Luna · sab 17 ott · Roma": the day shown, with its year when it is another one, and the place.
    private func cartiglio(for date: Date) -> String {
        let calendar = Calendar.current
        let day = if calendar.component(.year, from: date) == calendar.component(.year, from: .now) {
            date.formatted(.dateTime.weekday(.abbreviated).day().month(.abbreviated))
        } else {
            date.formatted(.dateTime.day().month(.abbreviated).year())
        }
        return (["Sbu", String(localized: "Luna"), day] + [placeName].compactMap(\.self))
            .joined(separator: " · ")
    }

    /// Rise and set on the day shown: a city's on its own clock, the iPhone's position on the iPhone's.
    private func riseSet(on date: Date) -> PlaceRiseSet? {
        guard let place = places.place else { return nil }
        return PlaceRiseSet(shownDate: date, coordinates: place.coordinates, timeZone: places.city?.zone, deviceCalendar: .current)
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
        .environment(\.sbuAccent, .moon)
        .tint(SbuTheme.ink)
}

#Preview("Dark") {
    MainView(model: MoonModel(), places: PlaceModel())
        .environment(\.sbuAccent, .moon)
        .tint(SbuTheme.ink)
        .preferredColorScheme(.dark)
}
