#if DEBUG
import Foundation

/// A TV that is always there, for previews, UI tests and App Store screenshots
/// (launch argument `-demoTV`). Never in release builds.
final class DemoTVClient: TVClient {
    let tv: SavedTV
    var onDisconnect: (@MainActor () -> Void)?
    let reportedDetails: TVDetails? = nil
    let supportedKeys = Set(RemoteKey.allCases)
    let holdsKeysNatively = true
    var hasPointer: Bool { tv.brand == .lg }
    private(set) var sent: [(RemoteKey, KeyAction)] = []
    private(set) var text = ""

    init(tv: SavedTV) {
        self.tv = tv
    }

    static let demoTV = SavedTV(id: UUID(uuidString: "5B0D7E1E-0000-4000-8000-000000000001") ?? UUID(), name: "Soggiorno", brand: .samsung, host: "192.168.1.20", macAddress: "A0:B1:C2:D3:E4:F5", model: "QE55Q80")

    static var isEnabled: Bool { ProcessInfo.processInfo.arguments.contains("-demoTV") }

    func connect() async throws {}
    func startPairing(allowingPlain: Bool) async throws -> PairingStep { .paired }
    func finishPairing(code: String) async throws {}
    func disconnect() {}

    func send(_ key: RemoteKey, _ action: KeyAction) async throws {
        sent.append((key, action))
    }

    func movePointer(dx: Double, dy: Double) async throws {}

    func sendText(_ text: String) async throws {
        self.text = text
    }

    func submitText() async throws {}

    func apps() async throws -> [TVShortcut] {
        [
            TVShortcut(id: "youtube", name: "YouTube"),
            TVShortcut(id: "netflix", name: "Netflix"),
            TVShortcut(id: "raiplay", name: "RaiPlay"),
            TVShortcut(id: "prime", name: "Prime Video"),
            TVShortcut(id: "spotify", name: "Spotify"),
        ]
    }

    func launch(_ app: TVShortcut) async throws {}

    func inputs() async throws -> [TVShortcut] {
        [TVShortcut(id: "hdmi1", name: "HDMI 1"), TVShortcut(id: "hdmi2", name: "PlayStation"), TVShortcut(id: "tv", name: "TV")]
    }

    func switchInput(_ input: TVShortcut) async throws {}
    func powerOn() async throws {}
}
#endif
