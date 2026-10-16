import Foundation
import Testing
@testable import SbuFind

struct FixedScannerTests {
    let defaults: UserDefaults

    init() throws {
        defaults = try #require(UserDefaults(suiteName: "FixedScannerTests-\(UUID().uuidString)"))
    }

    @Test func aNormalLaunchUsesTheRealScanner() {
        #expect(FixedScanner.requested(in: defaults) == nil)
    }

    @Test func screenshotsUseTheDemoDevices() throws {
        defaults.set(true, forKey: "FASTLANE_SNAPSHOT")
        let scanner = try #require(FixedScanner.requested(in: defaults))
        #expect(scanner.state == .ready)
        #expect(scanner.devices == FixedScanner.demoDevices)
    }

    @Test(arguments: BluetoothState.allCases)
    func aLaunchArgumentPicksTheState(state: BluetoothState) {
        defaults.set(state.rawValue, forKey: "FIXED_SCANNER")
        #expect(FixedScanner.requested(in: defaults)?.state == state)
    }

    @Test func demoMeansReady() {
        defaults.set("demo", forKey: "FIXED_SCANNER")
        #expect(FixedScanner.requested(in: defaults)?.state == .ready)
    }

    @Test func anUnknownArgumentUsesTheRealScanner() {
        defaults.set("bogus", forKey: "FIXED_SCANNER")
        #expect(FixedScanner.requested(in: defaults) == nil)
    }

    @Test func demoDevicesHaveDistinctIdentifiersAndValidReadings() {
        let devices = FixedScanner.demoDevices
        #expect(Set(devices.map(\.id)).count == devices.count)
        let allValid = devices.allSatisfy(\.hasValidRSSI)
        let someUnnamed = devices.contains { $0.name == nil }
        #expect(allValid)
        #expect(someUnnamed)
    }

    @Test func aReadyScannerSaysSoThenAdvertisesEveryDevice() async {
        let scanner = FixedScanner()
        var iterator = scanner.events().makeAsyncIterator()
        #expect(await iterator.next() == .state(.ready))

        var heard = Set<UUID>()
        while heard.count < FixedScanner.demoDevices.count, let event = await iterator.next() {
            if case .advertisement(let advertisement) = event {
                heard.insert(advertisement.id)
            }
        }
        scanner.stop()
        #expect(heard == Set(FixedScanner.demoDevices.map(\.id)))
    }

    @Test(arguments: BluetoothState.allCases.filter { $0 != .ready })
    func aScannerThatIsNotReadyOnlyReportsItsState(state: BluetoothState) async {
        let scanner = FixedScanner(state: state)
        let stream = scanner.events()
        scanner.stop()
        var events: [ScanEvent] = []
        for await event in stream {
            events.append(event)
        }
        #expect(events == [.state(state)])
    }
}
