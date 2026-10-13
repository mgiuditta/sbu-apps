import Foundation
@testable import SbuNoise

extension NoiseStore {
    /// A store on its own throwaway file, so tests never touch the app's.
    static var temporary: NoiseStore {
        NoiseStore(url: .temporaryDirectory.appending(path: "SbuNoiseTests-\(UUID().uuidString)/noise.json"))
    }
}
