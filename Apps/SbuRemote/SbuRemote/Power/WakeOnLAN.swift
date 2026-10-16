import Foundation
import Network

/// Sends the magic packet over UDP. Broadcast needs the multicast entitlement; until Apple
/// grants it, the packet goes to the TV's own address (`NetworkFeatures`).
enum WakeOnLAN {
    static func wake(_ tv: SavedTV) async {
        guard let mac = tv.macAddress, let packet = MagicPacket.packet(for: mac) else { return }
        let host = MagicPacket.destination(host: tv.host, isBroadcastAllowed: NetworkFeatures.isMulticastEntitled)
        let parameters = NWParameters.udp
        parameters.allowLocalEndpointReuse = true
        let connection = NWConnection(host: .init(host), port: .init(integerLiteral: MagicPacket.port), using: parameters)
        connection.start(queue: .main)
        // Three times, a moment apart: UDP may drop one, and a TV waking up may miss the first.
        for attempt in 0 ..< 3 {
            if attempt > 0 { try? await Task.sleep(for: .milliseconds(150)) }
            await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
                connection.send(content: packet, completion: .contentProcessed { _ in continuation.resume() })
            }
        }
        connection.cancel()
    }
}
