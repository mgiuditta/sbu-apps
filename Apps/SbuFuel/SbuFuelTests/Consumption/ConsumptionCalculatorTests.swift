import Foundation
import Testing
@testable import SbuFuel

struct ConsumptionCalculatorTests {
    nonisolated private static func day(_ n: Int) -> Date {
        Date(timeIntervalSince1970: 1_767_225_600 + Double(n) * 86_400)
    }

    nonisolated private static func fill(_ day: Int, _ km: Double, _ litres: Double, full: Bool = true, missed: Bool = false) -> FillRecord {
        FillRecord(date: Self.day(day), odometerKm: km, litres: litres, isFull: full, missedPrevious: missed)
    }

    nonisolated struct Case: CustomTestStringConvertible, Sendable {
        let name: String
        let fills: [FillRecord]
        let segments: Int
        /// Kilometres per litre over every closed segment.
        let average: Double?
        var testDescription: String { name }
    }

    nonisolated static let cases: [Case] = [
        Case(name: "nessun rifornimento", fills: [], segments: 0, average: nil),
        Case(name: "un solo pieno", fills: [Self.fill(0, 1_000, 40)], segments: 0, average: nil),
        Case(name: "due pieni: il primo serbatoio non conta", fills: [Self.fill(0, 1_000, 40), Self.fill(10, 1_500, 25)], segments: 1, average: 20),
        Case(name: "il parziale si somma al tratto", fills: [Self.fill(0, 1_000, 40), Self.fill(5, 1_300, 10, full: false), Self.fill(10, 1_600, 20)],
             segments: 1, average: 20),
        Case(name: "un parziale prima del primo pieno è ignorato", fills: [Self.fill(0, 900, 10, full: false), Self.fill(1, 1_000, 40), Self.fill(10, 1_500, 25)],
             segments: 1, average: 20),
        Case(name: "il salto rompe la catena", fills: [Self.fill(0, 1_000, 40), Self.fill(10, 1_500, 25), Self.fill(30, 2_400, 30, missed: true), Self.fill(40, 2_700, 20)],
             segments: 2, average: 800.0 / 45.0),
        Case(name: "il salto su un parziale apre un tratto solo al pieno dopo", fills: [Self.fill(0, 1_000, 40), Self.fill(10, 1_400, 10, full: false, missed: true),
                                                                                      Self.fill(20, 1_800, 30), Self.fill(30, 2_300, 25)],
             segments: 1, average: 20),
        Case(name: "inseriti in qualunque ordine", fills: [Self.fill(10, 1_600, 20), Self.fill(0, 1_000, 40), Self.fill(5, 1_300, 10, full: false)],
             segments: 1, average: 20),
        Case(name: "mai una media delle medie", fills: [Self.fill(0, 0, 40), Self.fill(1, 100, 10), Self.fill(2, 1_100, 50)],
             segments: 2, average: 1_100.0 / 60.0),
    ]

    @Test(arguments: cases)
    func fullToFull(_ example: Case) throws {
        let calculator = ConsumptionCalculator(example.fills)
        #expect(calculator.segments.count == example.segments)
        if let expected = example.average {
            let average = try #require(calculator.averageKmPerLitre)
            #expect(abs(average - expected) < 0.000_1)
        } else {
            #expect(calculator.averageKmPerLitre == nil)
        }
    }

    @Test func milesOdometerGivesTheSameConsumptionOnceInKilometres() throws {
        let miles = DistanceUnit.miles
        let fills = [
            FillRecord(date: Self.day(0), odometerKm: miles.km(from: 10_000), litres: 40),
            FillRecord(date: Self.day(9), odometerKm: miles.km(from: 10_300), litres: UnitConsumptionHelpers.litres(gallons: 10)),
        ]
        let average = try #require(ConsumptionCalculator(fills).averageKmPerLitre)
        // 300 miles on 10 US gallons is 30 mpg.
        #expect(abs(ConsumptionUnit.mpgUS.value(fromKmPerLitre: average) - 30) < 0.001)
    }

    @Test func bestAndWorstAreBySegmentAndTheLastIsByOdometer() throws {
        let calculator = ConsumptionCalculator([Self.fill(0, 0, 40), Self.fill(30, 1_200, 40), Self.fill(10, 500, 25), Self.fill(20, 900, 10)])
        let best = try #require(calculator.best)
        let worst = try #require(calculator.worst)
        let last = try #require(calculator.last)
        #expect(best.kmPerLitre == 40)
        #expect(worst.kmPerLitre == 7.5)
        #expect(last.endKm == 1_200)
    }

    @Test func segmentIsFoundByTheFuelUpThatClosesIt() throws {
        let closing = Self.fill(10, 1_500, 25)
        let calculator = ConsumptionCalculator([Self.fill(0, 1_000, 40), closing])
        #expect(calculator.segment(closedBy: closing.id)?.distanceKm == 500)
    }

    @Test func aRepeatedReadingClosesNothing() {
        let calculator = ConsumptionCalculator([Self.fill(0, 1_000, 40), Self.fill(1, 1_000, 5)])
        #expect(calculator.segments.isEmpty)
    }
}

/// Gallon arithmetic for tests, through Measurement like the app.
enum UnitConsumptionHelpers {
    static func litres(gallons: Double) -> Double {
        VolumeUnit.usGallons.litres(from: gallons)
    }
}
