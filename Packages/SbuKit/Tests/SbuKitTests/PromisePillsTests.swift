import Foundation
import Testing
@testable import SbuKit

/// The promise pills are fixed; only the data pill follows where the app keeps the data.
struct PromisePillsTests {
    @Test func everyAppSaysTheDataStaysOnThisIPhone() {
        let keys = SbuPromisePills().promisesKeys

        #expect(keys == ["Nessun account", "Nessuna pubblicità", "Nessun acquisto in-app", "Dati solo su questo iPhone"])
    }

    @Test func withICloudSyncTheDataStaysOnYourDevices() {
        let keys = SbuPromisePills(dataLocation: .yourDevices).promisesKeys

        #expect(keys == ["Nessun account", "Nessuna pubblicità", "Nessun acquisto in-app", "Dati solo sui tuoi dispositivi"])
    }

    @Test(arguments: [SbuDataLocation.thisDevice, .yourDevices])
    func everyPromiseIsTranslated(_ location: SbuDataLocation) {
        for promise in SbuPromisePills.promises(dataLocation: location) {
            var english = promise
            english.locale = Locale(identifier: "en")
            #expect(String(localized: english) != promise.key)
        }
    }
}

private extension SbuPromisePills {
    var promisesKeys: [String] {
        Self.promises(dataLocation: dataLocation).map(\.key)
    }
}
