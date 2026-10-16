import Foundation

/// A pairing message from the TV: its status and which step it answers.
nonisolated struct PoloReply: Equatable, Sendable {
    enum Kind: Equatable, Sendable {
        case pairingRequestAck, options, configurationAck, secretAck, other
    }

    let status: Int
    let kind: Kind

    var isOK: Bool { status == PoloMessage.statusOK }

    init?(_ data: Data) {
        guard let reader = ProtobufReader(data) else { return nil }
        status = reader.varints[PoloMessage.Field.status] ?? 0
        if reader.fields[PoloMessage.Field.pairingRequestAck] != nil {
            kind = .pairingRequestAck
        } else if reader.fields[PoloMessage.Field.options] != nil {
            kind = .options
        } else if reader.fields[PoloMessage.Field.configurationAck] != nil {
            kind = .configurationAck
        } else if reader.fields[PoloMessage.Field.secretAck] != nil {
            kind = .secretAck
        } else {
            kind = .other
        }
    }
}
