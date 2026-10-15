/// The sheet open over the top of the inventory: the scanner, or a label nothing has yet.
enum HomeSheet: Identifiable, Equatable {
    case scan
    case unknown(String)

    var id: String {
        switch self {
        case .scan: "scan"
        case let .unknown(code): "unknown-\(code)"
        }
    }
}
