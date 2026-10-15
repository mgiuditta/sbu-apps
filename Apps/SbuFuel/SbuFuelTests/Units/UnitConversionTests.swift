import Foundation
import Testing
@testable import SbuFuel

struct UnitConversionTests {
    @Test(arguments: [
        (ConsumptionUnit.litresPer100Km, 5.0),
        (.kmPerLitre, 20.0),
        (.mpgUS, 47.043),
        (.mpgUK, 56.497),
    ])
    func twentyKilometresPerLitre(unit: ConsumptionUnit, expected: Double) {
        #expect(abs(unit.value(fromKmPerLitre: 20) - expected) < 0.001)
    }

    @Test(arguments: ConsumptionUnit.allCases)
    func consumptionRoundTrips(unit: ConsumptionUnit) {
        let value = unit.value(fromKmPerLitre: 16.4)
        #expect(abs(unit.kmPerLitre(from: value) - 16.4) < 0.000_1)
    }

    @Test(arguments: [
        ("it_IT", ConsumptionUnit.litresPer100Km, VolumeUnit.litres, DistanceUnit.kilometres),
        ("de_DE", .litresPer100Km, .litres, .kilometres),
        ("en_US", .mpgUS, .usGallons, .miles),
        ("en_GB", .mpgUK, .litres, .miles),
    ])
    func defaultsFollowTheRegion(identifier: String, consumption: ConsumptionUnit, volume: VolumeUnit, distance: DistanceUnit) {
        let locale = Locale(identifier: identifier)
        #expect(ConsumptionUnit.preferred(for: locale) == consumption)
        #expect(VolumeUnit.preferred(for: locale) == volume)
        #expect(DistanceUnit.preferred(for: locale) == distance)
    }

    @Test(arguments: [
        (VolumeUnit.litres, 1.0),
        (.usGallons, 3.785_411_784),
        (.imperialGallons, 4.546_09),
    ])
    func oneUnitInLitres(unit: VolumeUnit, litres: Double) {
        #expect(abs(unit.litres(from: 1) - litres) < 0.000_1)
        #expect(abs(unit.value(fromLitres: litres) - 1) < 0.000_1)
    }

    @Test func milesConvertExactly() {
        #expect(abs(DistanceUnit.miles.km(from: 1) - 1.609_344) < 0.000_001)
        #expect(DistanceUnit.kilometres.km(from: 42) == 42)
    }

    @Test(arguments: [
        ("it_IT", "45.210\u{00A0}km", "42,50\u{00A0}L", "6,2"),
        ("en_US", "45,210\u{00A0}km", "42.50\u{00A0}L", "6.2"),
    ])
    func formattingFollowsTheLanguage(identifier: String, distance: String, volume: String, consumption: String) {
        let locale = Locale(identifier: identifier)
        #expect(DistanceUnit.kilometres.formatted(km: 45_210.4, locale: locale) == distance)
        #expect(VolumeUnit.litres.formatted(litres: 42.5, locale: locale) == volume)
        #expect(ConsumptionUnit.litresPer100Km.formatted(kmPerLitre: 100 / 6.2, locale: locale) == consumption)
    }

    @Test func settingsRememberTheChoiceOverTheRegion() throws {
        let defaults = try #require(UserDefaults(suiteName: "units-\(UUID())"))
        let settings = UnitSettings(defaults: defaults, locale: Locale(identifier: "it_IT"))
        #expect(settings.consumption == .litresPer100Km)
        settings.consumption = .kmPerLitre
        settings.volume = .imperialGallons
        let reopened = UnitSettings(defaults: defaults, locale: Locale(identifier: "en_US"))
        #expect(reopened.consumption == .kmPerLitre)
        #expect(reopened.volume == .imperialGallons)
    }

    @Test(arguments: [("it_IT", false), ("de_DE", false), ("en_US", true), ("en_GB", true)])
    func currencySymbolSideFollowsTheLanguage(identifier: String, first: Bool) {
        #expect(NumberField.currencySymbolFirst(locale: Locale(identifier: identifier)) == first)
    }

    @Test(arguments: [
        ("it_IT", Decimal(string: "1.789")!, "1,789\u{00A0}€/L"),
        ("en_US", Decimal(string: "1.789")!, "$1.789/L"),
    ])
    func pricePerUnitKeepsTheTenthOfACent(identifier: String, price: Decimal, expected: String) {
        #expect(Money.perUnit(price, symbol: "L", locale: Locale(identifier: identifier)) == expected)
    }
}
