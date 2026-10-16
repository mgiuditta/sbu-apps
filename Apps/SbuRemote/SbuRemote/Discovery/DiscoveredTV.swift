import Foundation

/// A TV found on the Wi-Fi, before pairing.
nonisolated struct DiscoveredTV: Hashable, Identifiable, Sendable {
    /// How to reach the TV: an address already known (SSDP, manual entry) or a Bonjour
    /// service that is resolved to an address when the user picks it.
    enum Address: Hashable, Sendable {
        case host(String)
        case bonjour(name: String, type: String)
    }

    let name: String
    let brand: TVBrand
    let address: Address
    let model: String?

    var id: String { "\(brand.rawValue)|\(name.lowercased())" }

    init(name: String, brand: TVBrand, address: Address, model: String? = nil) {
        self.name = name
        self.brand = brand
        self.address = address
        self.model = model
    }

    /// The TVs a set of Bonjour records and SSDP replies describe, one per TV and brand,
    /// sorted by name. A TV that announces both Android TV Remote and AirPlay shows once, as
    /// Android TV: that is the protocol Sbu Remote speaks to it.
    static func merge(bonjour: [BonjourRecord], ssdp: [SSDPResponse]) -> [DiscoveredTV] {
        var found: [String: DiscoveredTV] = [:]
        let androidNames = Set(bonjour.filter { $0.brand == .androidTV }.map { $0.name.lowercased() })

        for record in bonjour {
            guard let brand = record.brand else { continue }
            if brand != .androidTV, androidNames.contains(record.name.lowercased()) { continue }
            let tv = DiscoveredTV(name: record.name, brand: brand, address: .bonjour(name: record.name, type: record.type), model: record.model)
            found[tv.id] = found[tv.id] ?? tv
        }
        for reply in ssdp {
            guard let brand = reply.brand, let host = reply.host else { continue }
            // SSDP replies carry no friendly name without fetching the description; the address names the TV.
            let alreadyByBonjour = found.values.contains { $0.brand == brand && $0.address == .host(host) }
            guard !alreadyByBonjour else { continue }
            let tv = DiscoveredTV(name: host, brand: brand, address: .host(host))
            found[tv.id] = tv
        }
        return found.values.sorted { $0.name.localizedStandardCompare($1.name) == .orderedAscending }
    }
}
