import CoreBluetooth
import Testing
@testable import SbuFind

struct BluetoothStateTests {
    @Test(arguments: [
        (CBManagerState.poweredOn, BluetoothState.ready),
        (.poweredOff, .poweredOff),
        (.unauthorized, .denied),
        (.unsupported, .unsupported),
        (.resetting, .resetting),
        (.unknown, .starting),
    ])
    func allowedAppFollowsTheRadio(managerState: CBManagerState, expected: BluetoothState) {
        #expect(BluetoothState(managerState: managerState, authorization: .allowedAlways) == expected)
    }

    @Test(arguments: [CBManagerState.poweredOn, .poweredOff, .unauthorized, .unsupported, .resetting, .unknown])
    func deniedWinsOverAnyRadioState(managerState: CBManagerState) {
        #expect(BluetoothState(managerState: managerState, authorization: .denied) == .denied)
    }

    @Test(arguments: [CBManagerState.poweredOn, .poweredOff, .unauthorized, .unknown])
    func restrictedWinsOverAnyRadioState(managerState: CBManagerState) {
        #expect(BluetoothState(managerState: managerState, authorization: .restricted) == .restricted)
    }

    @Test(arguments: [
        (CBManagerState.unknown, BluetoothState.starting),
        (.poweredOn, .ready),
        (.unauthorized, .denied),
    ])
    func notAskedYetFollowsTheRadio(managerState: CBManagerState, expected: BluetoothState) {
        #expect(BluetoothState(managerState: managerState, authorization: .notDetermined) == expected)
    }
}
