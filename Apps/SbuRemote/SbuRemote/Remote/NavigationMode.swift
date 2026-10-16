/// How the user moves around the TV's menus: arrow keys or the touchpad.
nonisolated enum NavigationMode: String, CaseIterable, Identifiable, Sendable {
    case dPad
    case touchpad

    var id: Self { self }

    var systemImage: String {
        switch self {
        case .dPad: "dpad"
        case .touchpad: "hand.point.up.left"
        }
    }
}
