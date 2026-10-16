import Network
import Observation

/// Watches the phone's network: each change of Wi-Fi bumps `generation`.
@Observable
final class NetworkMonitor {
    private(set) var generation = 0
    /// On Wi-Fi or Ethernet, where the TV can be.
    private(set) var isOnLocalNetwork = true

    @ObservationIgnored private let monitor = NWPathMonitor()
    @ObservationIgnored private var lastSignature: String?

    init() {
        monitor.pathUpdateHandler = { [weak self] path in
            let local = path.status == .satisfied && (path.usesInterfaceType(.wifi) || path.usesInterfaceType(.wiredEthernet))
            let signature = "\(local)|" + path.availableInterfaces.map(\.name).joined(separator: ",")
            Task { @MainActor in self?.update(signature: signature, isOnLocalNetwork: local) }
        }
        monitor.start(queue: .main)
    }

    deinit {
        monitor.cancel()
    }

    private func update(signature: String, isOnLocalNetwork: Bool) {
        // The first path is the one the app starts on, not a change.
        defer { lastSignature = signature }
        guard let lastSignature, lastSignature != signature else { return }
        self.isOnLocalNetwork = isOnLocalNetwork
        generation += 1
    }
}
