import Foundation
import Observation

/// Pairs one TV: finds its address, opens its protocol, waits for the prompt or the code.
@Observable
final class PairingModel {
    enum Phase: Equatable {
        /// Before the user taps Collega.
        case ready
        /// Talking to the TV; the TV may be showing its prompt.
        case waiting
        case code(length: Int, isHexadecimal: Bool)
        /// The TV has no TLS: the user decides whether to go on in plain text.
        case confirmPlain
        case failed(TVClientError)
        case paired
    }

    let candidate: TVCandidate
    private(set) var phase = Phase.ready
    private(set) var tv: SavedTV?

    @ObservationIgnored private var client: (any TVClient)?
    @ObservationIgnored private let makeClient: @MainActor (SavedTV) -> any TVClient

    init(candidate: TVCandidate, makeClient: @escaping @MainActor (SavedTV) -> any TVClient = TVClientFactory.client(for:)) {
        self.candidate = candidate
        self.makeClient = makeClient
    }

    var brand: TVBrand { candidate.brand }

    /// Starts pairing; `allowingPlain` once the user confirmed plain text.
    func start(allowingPlain: Bool = false) async {
        phase = .waiting
        do {
            let tv = try await savedTV()
            let client = client ?? makeClient(tv)
            self.client = client
            switch try await client.startPairing(allowingPlain: allowingPlain) {
            case .paired:
                finish(with: client)
            case .code(let length, let isHexadecimal):
                phase = .code(length: length, isHexadecimal: isHexadecimal)
            }
        } catch let error as TVClientError {
            phase = error == .needsPlainConfirmation ? .confirmPlain : .failed(error)
        } catch {
            phase = .failed(.unreachable)
        }
    }

    func submit(code: String) async {
        guard let client, case .code = phase else { return }
        phase = .waiting
        do {
            try await client.finishPairing(code: code)
            finish(with: client)
        } catch let error as TVClientError {
            phase = .failed(error)
        } catch {
            phase = .failed(.unreachable)
        }
    }

    /// Sony only: the pre-shared key set on the TV instead of the PIN.
    func submit(preSharedKey: String) async {
        guard let sony = client as? SonyClient else { return }
        phase = .waiting
        do {
            try await sony.pair(preSharedKey: preSharedKey)
            finish(with: sony)
        } catch let error as TVClientError {
            phase = .failed(error)
        } catch {
            phase = .failed(.unreachable)
        }
    }

    func cancel() {
        client?.disconnect()
        client = nil
    }

    private func finish(with client: any TVClient) {
        guard var tv else { return }
        if let details = client.reportedDetails {
            if let name = details.name, !name.isEmpty, candidate.address.isHost { tv.name = name }
            tv.model = details.model ?? tv.model
            tv.macAddress = details.macAddress ?? tv.macAddress
        }
        client.disconnect()
        self.tv = tv
        phase = .paired
    }

    private func savedTV() async throws -> SavedTV {
        if let tv { return tv }
        let host: String
        switch candidate.address {
        case .host(let address):
            host = address
        case .bonjour(let name, let type):
            guard let resolved = await AddressResolver.host(forService: name, type: type) else { throw TVClientError.unreachable }
            host = resolved
        }
        let tv = SavedTV(name: candidate.name, brand: candidate.brand, host: host, model: candidate.model)
        self.tv = tv
        return tv
    }
}

private extension DiscoveredTV.Address {
    /// A TV added by address has only its IP as a name, so the name the TV reports is better.
    var isHost: Bool {
        if case .host = self { return true }
        return false
    }
}
