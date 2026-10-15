import Foundation
import SwiftData
import Testing
@testable import SbuFuel

struct FuelUpDraftTests {
    private let italian = Locale(identifier: "it_IT")
    private let calendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Europe/Rome")!
        return calendar
    }()

    private func date(_ month: Int, _ day: Int) -> Date {
        calendar.date(from: DateComponents(year: 2026, month: month, day: day, hour: 12))!
    }

    private func draft(_ odometer: String, _ quantity: String = "40", price: String = "", kind: FuelUpDraft.PriceKind = .total) -> FuelUpDraft {
        var draft = FuelUpDraft(distanceUnit: .kilometres, volumeUnit: .litres, locale: italian)
        draft.odometerText = odometer
        draft.quantityText = quantity
        draft.priceText = price
        draft.priceKind = kind
        return draft
    }

    @Test(arguments: [("45.210", 45_210.0), ("45210", 45_210.0), ("45210,5", 45_210.5), ("45210.5", 45_210.5)])
    func odometerReadsItalianTyping(text: String, km: Double) {
        #expect(draft(text).odometerKm == km)
    }

    @Test func totalGivesThePricePerLitre() {
        let draft = draft("45210", "38,4", price: "68,70")
        #expect(draft.totalPrice == Decimal(string: "68.70"))
        #expect(draft.unitPrice == Decimal(string: "1.789"))
    }

    @Test func pricePerLitreGivesTheTotalToTheCent() {
        let draft = draft("45210", "38,4", price: "1,789", kind: .perUnit)
        #expect(draft.totalPrice == Decimal(string: "68.70"))
    }

    @Test func anEmptyPriceIsAFreeFill() {
        #expect(draft("45210").totalPrice == 0)
    }

    @Test func gallonsAndMilesAreStoredInLitresAndKilometres() throws {
        var draft = FuelUpDraft(distanceUnit: .miles, volumeUnit: .usGallons, locale: Locale(identifier: "en_US"))
        draft.odometerText = "12,300"
        draft.quantityText = "10"
        let record = try #require(draft.record())
        #expect(abs(record.odometerKm - 19_794.9312) < 0.001)
        #expect(abs(record.litres - 37.854_117_84) < 0.000_1)
    }

    @Test func editingShowsTheSavedValuesBack() {
        let record = FillRecord(date: date(3, 1), odometerKm: 45_210, litres: 38.4, isFull: false, totalPrice: Decimal(string: "68.7")!)
        let draft = FuelUpDraft(record, station: "Q8", note: "", distanceUnit: .kilometres, volumeUnit: .litres, locale: italian)
        #expect(draft.odometerText == "45210")
        #expect(draft.quantityText == "38,4")
        #expect(draft.priceText == "68,7")
        #expect(!draft.isFull)
        #expect(draft.record()?.odometerKm == 45_210)
    }

    @Test(arguments: [("", FuelUpDraft.Problem.missingOdometer), ("0", .missingOdometer)])
    func missingReading(text: String, problem: FuelUpDraft.Problem) {
        #expect(draft(text).problem(id: nil, among: [], calendar: calendar) == problem)
    }

    @Test func missingQuantity() {
        #expect(draft("45000", "").problem(id: nil, among: [], calendar: calendar) == .missingQuantity)
    }

    private var readings: [OdometerReading] {
        [
            OdometerReading(id: UUID(), date: date(3, 1), km: 45_000, source: .fuelUp),
            OdometerReading(id: UUID(), date: date(3, 20), km: 46_000, source: .fuelUp),
            OdometerReading(id: UUID(), date: date(3, 10), km: 45_500, source: .service),
        ]
    }

    @Test func aLateEntryBetweenItsNeighboursIsFine() {
        var late = draft("45300")
        late.date = date(3, 5)
        #expect(late.problem(id: nil, among: readings, calendar: calendar) == nil)
    }

    @Test func aReadingLowerThanAnEarlierEntryNamesIt() throws {
        var late = draft("45400")
        late.date = date(3, 15)
        let problem = try #require(late.problem(id: nil, among: readings, calendar: calendar))
        guard case let .conflict(.earlierIsHigher(reading)) = problem else {
            Issue.record("Expected an earlier, higher reading, got \(problem)")
            return
        }
        #expect(reading.km == 45_500)
    }

    @Test func aReadingHigherThanALaterEntryNamesIt() throws {
        var early = draft("46100")
        early.date = date(3, 15)
        guard case let .conflict(.laterIsLower(reading)) = try #require(early.problem(id: nil, among: readings, calendar: calendar)) else {
            Issue.record("Expected a later, lower reading")
            return
        }
        #expect(reading.km == 46_000)
    }

    @Test func theSameReadingTwiceIsCaught() {
        var twice = draft("45000")
        twice.date = date(3, 1)
        guard case .conflict(.sameReading) = twice.problem(id: nil, among: readings, calendar: calendar) else {
            Issue.record("Expected the same reading")
            return
        }
    }

    @Test func editingAnEntryIsNotAClashWithItself() {
        let readings = readings
        let own = readings[0]
        var edit = draft("45000")
        edit.date = own.date
        #expect(edit.problem(id: own.id, among: readings, calendar: calendar) == nil)
    }

    @Test func entriesOfTheSameDayCanBeInAnyOrder() {
        var sameDay = draft("44900")
        sameDay.date = date(3, 1)
        #expect(sameDay.problem(id: nil, among: readings, calendar: calendar) == nil)
    }

    @Test func aServiceMovesItsReminderForward() throws {
        let container = try ModelContainer.fuel(inMemory: true)
        let context = container.mainContext
        let vehicle = Vehicle(name: "Panda")
        context.insert(vehicle)
        let oil = ServiceReminder(vehicle: vehicle, kind: .oilChange, title: "Cambio olio", everyKm: 15_000, everyMonths: 12,
                                  lastDoneDate: date(1, 1), lastDoneOdometerKm: 30_000)
        let tax = ServiceReminder(vehicle: vehicle, kind: .tax, title: "Bollo", everyKm: nil, everyMonths: 12, lastDoneDate: date(1, 1), lastDoneOdometerKm: nil)
        context.insert(oil)
        context.insert(tax)
        let service = ServiceEntry(vehicle: vehicle, kind: .oilChange, title: "Tagliando", date: date(6, 1), odometerKm: 44_000, cost: 120, currencyCode: "EUR")
        context.insert(service)
        vehicle.rollReminders(for: service)
        #expect(oil.lastDoneDate == date(6, 1))
        #expect(oil.lastDoneOdometerKm == 44_000)
        #expect(tax.lastDoneDate == date(1, 1))
    }

    @Test func anOlderServiceDoesNotMoveTheReminderBack() throws {
        let container = try ModelContainer.fuel(inMemory: true)
        let context = container.mainContext
        let vehicle = Vehicle(name: "Panda")
        context.insert(vehicle)
        let oil = ServiceReminder(vehicle: vehicle, kind: .oilChange, title: "Cambio olio", everyKm: 15_000, everyMonths: nil,
                                  lastDoneDate: date(6, 1), lastDoneOdometerKm: 44_000)
        context.insert(oil)
        let old = ServiceEntry(vehicle: vehicle, kind: .oilChange, title: "Cambio olio", date: date(1, 1), odometerKm: 30_000, cost: 80, currencyCode: "EUR")
        context.insert(old)
        vehicle.rollReminders(for: old)
        #expect(oil.lastDoneOdometerKm == 44_000)
    }

    @Test func reminderPresetsFollowTheVehicleUnit() {
        var kilometres = ReminderDraft(distanceUnit: .kilometres, locale: italian)
        kilometres.apply(.oilChange)
        #expect(kilometres.everyKmText == "15000")
        #expect(kilometres.everyMonths == 12)
        var miles = ReminderDraft(distanceUnit: .miles, locale: Locale(identifier: "en_US"))
        miles.apply(.oilChange)
        #expect(miles.everyKmText == "9500")
        var tax = ReminderDraft(distanceUnit: .kilometres, locale: italian)
        tax.apply(.tax)
        #expect(tax.everyKmText.isEmpty)
        #expect(tax.problem == nil)
    }

    @Test func aReminderNeedsAnIntervalAndADistanceNeedsALastReading() {
        var draft = ReminderDraft(distanceUnit: .kilometres, locale: italian)
        draft.title = "Gomme"
        #expect(draft.problem == .noInterval)
        draft.everyKmText = "20000"
        #expect(draft.problem == .missingLastReading)
        draft.lastOdometerText = "40000"
        #expect(draft.canSave)
    }
}
