import CoreLocation
import Testing
@testable import SbuSpeed

struct SpeedStatusTests {
    @Test(arguments: [
        (CLAuthorizationStatus.notDetermined, CLAccuracyAuthorization.fullAccuracy, LocationAccess.notDetermined),
        (.denied, .fullAccuracy, .denied),
        (.restricted, .fullAccuracy, .denied),
        (.authorizedWhenInUse, .fullAccuracy, .granted),
        (.authorizedWhenInUse, .reducedAccuracy, .approximate),
        (.authorizedAlways, .fullAccuracy, .granted),
    ])
    func accessFromCoreLocation(status: CLAuthorizationStatus, accuracy: CLAccuracyAuthorization, expected: LocationAccess) {
        #expect(LocationAccess(status: status, accuracy: accuracy) == expected)
    }

    @Test(arguments: [
        (LocationAccess.notDetermined, nil, SpeedStatus.needsAccess),
        (.denied, nil, .denied),
        (.approximate, nil, .approximate),
        (.granted, nil, .searching),
        (.granted, 0.0, .still),
        (.granted, 0.29, .still),
        (.granted, 0.3, .moving),
        (.granted, 25, .moving),
    ] as [(LocationAccess, Double?, SpeedStatus)])
    func statusLine(access: LocationAccess, speed: Double?, expected: SpeedStatus) {
        #expect(SpeedStatus(access: access, speed: speed) == expected)
    }

    @Test(arguments: [
        (SpeedStatus.denied, true),
        (.approximate, true),
        (.needsAccess, false),
        (.searching, false),
        (.moving, false),
    ])
    func onlyMissingAccessSendsToSettings(status: SpeedStatus, needsSettings: Bool) {
        #expect(status.needsSettings == needsSettings)
    }
}
