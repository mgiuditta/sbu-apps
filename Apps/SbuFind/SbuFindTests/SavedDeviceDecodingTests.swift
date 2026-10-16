import Foundation
import Testing
@testable import SbuFind

struct SavedDeviceDecodingTests {
    /// A device saved before services were recorded comes back with none.
    @Test func aDeviceSavedBeforeServicesDecodesWithNone() throws {
        let json = """
        {"id":"\(UUID().uuidString)","name":"Mie","deviceID":"\(Advertisement.testID(1).uuidString)","advertisedName":"Buds Pro","kind":"earbuds"}
        """
        let saved = try JSONDecoder().decode(SavedDevice.self, from: Data(json.utf8))
        #expect(saved.serviceUUIDs.isEmpty)
        #expect(!saved.canBeFollowedInBackground)
        #expect(saved.companyID == nil)
    }

    @Test func theRosterGathersEveryServiceADeviceAdvertises() throws {
        var roster = DeviceRoster()
        roster.record(.fixture(serviceUUIDs: ["180d"]))
        roster.record(.fixture(serviceUUIDs: ["180F"], after: 1))
        roster.record(.fixture(after: 2))
        let device = try #require(roster.device(id: Advertisement.testID(1)))
        #expect(device.serviceUUIDs == ["180D", "180F"])
    }
}
