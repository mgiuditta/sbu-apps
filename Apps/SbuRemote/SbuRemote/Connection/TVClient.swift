import Foundation

/// One TV's protocol: pairing, keys, text, apps, inputs, power. Each brand has its client;
/// message encoding lives in pure types next to it, tested without a TV.
protocol TVClient: AnyObject {
    var tv: SavedTV { get }
    /// The keys this protocol can send; the remote dims the others.
    var supportedKeys: Set<RemoteKey> { get }
    /// Whether a held key goes as one press and one release (`KeyAction.press`/`.release`),
    /// so the TV repeats it itself. Otherwise the remote repeats clicks.
    var holdsKeysNatively: Bool { get }
    /// Whether the touchpad moves a free pointer (LG) instead of stepping the focus.
    var hasPointer: Bool { get }
    /// Name, model and MAC the TV reported while pairing.
    var reportedDetails: TVDetails? { get }
    /// Called when an open connection drops on its own.
    var onDisconnect: (@MainActor () -> Void)? { get set }

    /// Opens the remote channel with the saved credential; throws `.notPaired` without one.
    func connect() async throws
    /// Starts pairing: the TV shows a prompt or a code. Over TLS unless the user confirmed
    /// plain text for a legacy model (`allowingPlain`); throws `.needsPlainConfirmation` to ask.
    func startPairing(allowingPlain: Bool) async throws -> PairingStep
    /// Finishes pairing with the code the TV shows.
    func finishPairing(code: String) async throws
    func disconnect()

    func send(_ key: RemoteKey, _ action: KeyAction) async throws
    /// Moves the pointer, in points of the touchpad. Only when `hasPointer`.
    func movePointer(dx: Double, dy: Double) async throws
    /// A tap on the touchpad: a click where the pointer is (LG), OK elsewhere.
    func clickPointer() async throws
    /// Makes the TV's active text field read `text`.
    func sendText(_ text: String) async throws
    /// Confirms the TV's active text field, like Enter.
    func submitText() async throws
    /// The apps installed on the TV; empty where the protocol does not list them.
    func apps() async throws -> [TVShortcut]
    func launch(_ app: TVShortcut) async throws
    /// The TV's inputs (HDMI 1, AV); empty where only the Source key exists.
    func inputs() async throws -> [TVShortcut]
    func switchInput(_ input: TVShortcut) async throws
    /// Turns the TV on through the protocol, when it listens in standby.
    func powerOn() async throws
}

extension TVClient {
    var hasPointer: Bool { false }
    func movePointer(dx: Double, dy: Double) async throws { throw TVClientError.unsupported }
    func clickPointer() async throws { try await send(.select, .click) }
    func inputs() async throws -> [TVShortcut] { [] }
    func switchInput(_ input: TVShortcut) async throws { throw TVClientError.unsupported }
    func powerOn() async throws { throw TVClientError.unsupported }
}
