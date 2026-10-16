import Foundation
@testable import SbuFind

extension Advertisement {
    static let start = Date(timeIntervalSinceReferenceDate: 800_000_000)

    /// A fixed identifier for test device `number`.
    static func testID(_ number: Int) -> UUID {
        let digits = String(number)
        return UUID(uuidString: "10000000-0000-4000-8000-" + String(repeating: "0", count: 12 - digits.count) + digits) ?? UUID()
    }

    static func fixture(
        device: Int = 1,
        name: String? = "Buds Pro",
        rssi: Int = -60,
        manufacturerData: Data? = nil,
        serviceUUIDs: [String] = [],
        after seconds: TimeInterval = 0
    ) -> Advertisement {
        Advertisement(
            id: testID(device),
            name: name,
            rssi: rssi,
            manufacturerData: manufacturerData,
            serviceUUIDs: serviceUUIDs,
            date: start.addingTimeInterval(seconds)
        )
    }
}
