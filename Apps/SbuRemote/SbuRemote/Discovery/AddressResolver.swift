import Foundation
import Network

/// Turns a Bonjour service into the TV's IP address, by opening a TCP connection to it and
/// reading the address the path ends at. The connection is closed straight away.
enum AddressResolver {
    static func host(forService name: String, type: String, timeout: Duration = .seconds(5)) async -> String? {
        let connection = NWConnection(to: .service(name: name, type: type, domain: "local.", interface: nil), using: .tcp)
        defer { connection.cancel() }
        let resolved = AsyncStream<String?> { continuation in
            connection.stateUpdateHandler = { state in
                switch state {
                case .ready:
                    if case .hostPort(let host, _) = connection.currentPath?.remoteEndpoint {
                        continuation.yield(Self.text(of: host))
                    } else {
                        continuation.yield(nil)
                    }
                    continuation.finish()
                case .failed, .cancelled:
                    continuation.yield(nil)
                    continuation.finish()
                default:
                    break
                }
            }
            connection.start(queue: .main)
        }
        return await withTaskGroup(of: String?.self) { group in
            group.addTask {
                for await host in resolved { return host }
                return nil
            }
            group.addTask {
                try? await Task.sleep(for: timeout)
                return nil
            }
            let first = await group.next() ?? nil
            group.cancelAll()
            return first
        }
    }

    /// The address without the interface suffix iOS adds to link-local IPv6 (`fe80::1%en0`).
    nonisolated static func text(of host: NWEndpoint.Host) -> String {
        switch host {
        case .ipv4(let address):
            "\(address)"
        case .ipv6(let address):
            "\(address)".components(separatedBy: "%").first ?? "\(address)"
        case .name(let name, _):
            name
        @unknown default:
            "\(host)"
        }
    }
}
