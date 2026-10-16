import Foundation

/// Messages of the LG pointer socket: plain text, `key:value` lines, a blank line at the end.
nonisolated enum LGPointerMessage {
    static func button(_ name: String) -> String {
        "type:button\nname:\(name)\n\n"
    }

    /// Moves the pointer by whole points; LG wants integers.
    static func move(dx: Double, dy: Double) -> String {
        "type:move\ndx:\(Int(dx.rounded()))\ndy:\(Int(dy.rounded()))\ndown:0\n\n"
    }

    static let click = "type:click\n\n"

    /// The pointer button of a key; `nil` for keys that go as SSAP requests.
    static func buttonName(for key: RemoteKey) -> String? {
        switch key {
        case .home: "HOME"
        case .back: "BACK"
        case .up: "UP"
        case .down: "DOWN"
        case .left: "LEFT"
        case .right: "RIGHT"
        case .select: "ENTER"
        case .options: "MENU"
        default: nil
        }
    }
}
