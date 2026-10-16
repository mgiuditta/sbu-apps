import Foundation

/// The TV the user picked to pair: found on the Wi-Fi or typed by address.
nonisolated struct TVCandidate: Hashable, Identifiable, Sendable {
    let name: String
    let brand: TVBrand
    let address: DiscoveredTV.Address
    let model: String?

    var id: String { "\(brand.rawValue)|\(address)" }

    init(_ tv: DiscoveredTV) {
        name = tv.name
        brand = tv.brand
        address = tv.address
        model = tv.model
    }

    init(host: String, brand: TVBrand) {
        name = host
        self.brand = brand
        address = .host(host)
        model = nil
    }
}
