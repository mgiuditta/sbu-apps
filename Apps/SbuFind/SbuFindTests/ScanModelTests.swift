import Foundation
import Testing
@testable import SbuFind

struct ScanModelTests {
    let defaults: UserDefaults
    let scanner = FakeScanner()

    init() throws {
        defaults = try #require(UserDefaults(suiteName: "ScanModelTests-\(UUID().uuidString)"))
    }

    private func makeModel() -> ScanModel {
        ScanModel(scanner: scanner, defaults: defaults)
    }

    @Test func startsWaitingForBluetoothWithAnEmptyList() {
        let model = makeModel()
        #expect(model.state == .starting)
        #expect(model.devices.isEmpty)
        #expect(model.hiddenUnnamedCount == 0)
        #expect(model.showsUnnamed == false)
    }

    @Test func advertisementsReachTheScreenAtTheNextRefresh() {
        let model = makeModel()
        model.handle(.state(.ready))
        model.handle(.advertisement(.fixture(device: 1, name: "Buds", rssi: -70)))
        #expect(model.devices.isEmpty)

        model.refresh(at: Advertisement.start)
        #expect(model.devices.map(\.name) == ["Buds"])
    }

    @Test func theListIsSortedAndHidesTheUnnamed() {
        let model = makeModel()
        model.handle(.state(.ready))
        model.handle(.advertisement(.fixture(device: 1, name: "Lontano", rssi: -90)))
        model.handle(.advertisement(.fixture(device: 2, name: "Vicino", rssi: -45)))
        model.handle(.advertisement(.fixture(device: 3, name: nil, rssi: -40)))
        model.refresh(at: Advertisement.start)

        #expect(model.devices.map(\.name) == ["Vicino", "Lontano"])
        #expect(model.hiddenUnnamedCount == 1)
    }

    @Test func showingTheUnnamedListsThemAtOnceAndIsSaved() {
        let model = makeModel()
        model.handle(.advertisement(.fixture(device: 1, name: nil, rssi: -40)))
        model.refresh(at: Advertisement.start)
        #expect(model.devices.isEmpty)

        model.showsUnnamed = true

        #expect(model.devices.count == 1)
        #expect(model.hiddenUnnamedCount == 0)
        #expect(defaults.bool(forKey: "showsUnnamed"))
        #expect(ScanModel(scanner: FakeScanner(), defaults: defaults).showsUnnamed)
    }

    @Test(arguments: BluetoothState.allCases.filter { $0 != .ready })
    func losingBluetoothEmptiesTheList(state: BluetoothState) {
        let model = makeModel()
        model.handle(.state(.ready))
        model.handle(.advertisement(.fixture()))
        model.refresh(at: Advertisement.start)
        #expect(model.devices.count == 1)

        model.handle(.state(state))

        #expect(model.state == state)
        #expect(model.devices.isEmpty)
        model.refresh(at: Advertisement.start)
        #expect(model.devices.isEmpty)
    }

    @Test func aSilentDeviceLeavesAtARefresh() {
        let model = makeModel()
        model.handle(.advertisement(.fixture(device: 1, name: "Muto")))
        model.handle(.advertisement(.fixture(device: 2, name: "Parla", after: 12)))
        model.refresh(at: Advertisement.start.addingTimeInterval(12))
        #expect(model.devices.map(\.name) == ["Parla"])
    }

    @Test func rescanForgetsEveryDeviceAndRestartsTheScanner() {
        let model = makeModel()
        model.handle(.advertisement(.fixture()))
        model.refresh(at: Advertisement.start)

        model.rescan()

        #expect(model.devices.isEmpty)
        #expect(scanner.restarts == 1)
        model.refresh(at: Advertisement.start)
        #expect(model.devices.isEmpty)
    }

    @Test func runReadsTheScannerUntilItFinishesThenStopsIt() async {
        let model = makeModel()
        let running = Task {
            await model.run()
        }
        await Task.yield()
        scanner.send(.state(.ready))
        scanner.send(.advertisement(.fixture()))
        scanner.finish()
        await running.value

        #expect(model.state == .ready)
        #expect(scanner.stops == 1)
        model.refresh(at: Advertisement.start)
        #expect(model.devices.count == 1)
    }

    @Test func cancellingRunStopsTheScanner() async {
        let model = makeModel()
        let running = Task {
            await model.run()
        }
        await Task.yield()
        running.cancel()
        await running.value
        #expect(scanner.stops == 1)
    }
}
