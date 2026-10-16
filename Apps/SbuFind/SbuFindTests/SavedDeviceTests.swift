import Foundation
import Testing
@testable import SbuFind

struct SavedDeviceTests {
    @Test(arguments: [
        ("Le mie cuffie", "Buds Pro", "Le mie cuffie"),
        ("  Le mie cuffie \n", "Buds Pro", "Le mie cuffie"),
        ("", "Buds Pro", "Buds Pro"),
        ("   ", "Buds Pro", "Buds Pro"),
    ] as [(String, String?, String)])
    func yourNameIsTrimmedAndBlankFallsBack(typed: String, fallback: String?, expected: String) {
        #expect(SavedDevice.displayName(typed, fallback: fallback) == expected)
    }

    @Test func aBlankNameWithoutFallbackSaysNoName() {
        #expect(!SavedDevice.displayName("", fallback: nil).isEmpty)
    }

    @Test func aLongNameIsCutAtFortyCharacters() {
        #expect(SavedDevice.displayName(String(repeating: "a", count: 100), fallback: nil).count == 40)
    }

    @Test func savingKeepsWhatTheDeviceSaysAboutItself() {
        let device = NearbyDevice(id: Advertisement.testID(3), name: "Buds Pro", kind: .earbuds, signal: -50, lastSeen: Advertisement.start, companyID: 0x0075)
        let saved = SavedDevice(name: "Mie", device: device)
        #expect(saved.deviceID == device.id)
        #expect(saved.advertisedName == "Buds Pro")
        #expect(saved.kind == .earbuds)
        #expect(saved.companyID == 0x0075)
    }

    @Test func survivesEncoding() throws {
        let saved = SavedDevice(name: "Mie", device: NearbyDevice(id: Advertisement.testID(3), name: nil, kind: .other, signal: -50, lastSeen: Advertisement.start))
        #expect(try JSONDecoder().decode(SavedDevice.self, from: JSONEncoder().encode(saved)) == saved)
    }

    @Test func theStoreKeepsThemOutOfBackups() throws {
        let store = MyDevicesStore(url: URL.temporaryDirectory.appending(path: "mine-\(UUID().uuidString).json"))
        #expect(store.load().isEmpty)
        let saved = [SavedDevice(name: "Mie", device: NearbyDevice(id: Advertisement.testID(3), name: "X", kind: .other, signal: -50, lastSeen: Advertisement.start))]
        store.save(saved)
        #expect(store.load() == saved)
        #expect(try store.url.resourceValues(forKeys: [.isExcludedFromBackupKey]).isExcludedFromBackup == true)
    }
}
