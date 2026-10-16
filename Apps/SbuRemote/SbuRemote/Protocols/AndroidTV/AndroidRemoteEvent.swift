import Foundation

/// A remote message from an Android TV, reduced to what the client answers or keeps.
nonisolated enum AndroidRemoteEvent: Equatable, Sendable {
    case configure
    case setActive
    case ping(Int)
    /// The TV's text field changed: the counters to echo when sending text.
    case ime(imeCounter: Int, fieldCounter: Int)
    case error
    case other

    init(_ data: Data) {
        guard let reader = ProtobufReader(data) else {
            self = .other
            return
        }
        typealias Field = AndroidRemoteMessage.Field
        if reader.fields[Field.configure] != nil {
            self = .configure
        } else if reader.fields[Field.setActive] != nil {
            self = .setActive
        } else if let ping = reader.message(Field.pingRequest) {
            self = .ping(ping.varints[1] ?? 0)
        } else if let edit = reader.message(Field.imeBatchEdit) {
            self = .ime(imeCounter: edit.varints[1] ?? 0, fieldCounter: edit.varints[2] ?? 0)
        } else if reader.fields[Field.error] != nil {
            self = .error
        } else {
            self = .other
        }
    }
}
