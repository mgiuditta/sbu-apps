import Foundation

/// Pairing messages of Android TV Remote v2 (the "Polo" protocol, port 6467).
///
/// Field numbers from the public `polo.proto` that open-source clients describe (androidtvremote2,
/// androidtv-remote). Flow: pairing request, options, configuration; the TV shows a 6-character
/// hexadecimal code; the client sends the secret built from it (`PairingSecret`).
/// Verified only with unit tests; the whole exchange needs a test on a real Android TV.
nonisolated enum PoloMessage {
    static let protocolVersion = 2
    static let statusOK = 200
    static let hexadecimalEncoding = 3
    static let codeLength = 6
    static let roleInput = 1

    enum Field {
        static let protocolVersion = 1
        static let status = 2
        static let pairingRequest = 10
        static let pairingRequestAck = 11
        static let options = 20
        static let configuration = 30
        static let configurationAck = 31
        static let secret = 40
        static let secretAck = 41
    }

    static func pairingRequest(clientName: String) -> Data {
        outer { writer in
            writer.message(Field.pairingRequest) { request in
                request.string(1, "atvremote")
                request.string(2, clientName)
            }
        }
    }

    /// The client takes the input role and types a 6-character hexadecimal code.
    static func options() -> Data {
        outer { writer in
            writer.message(Field.options) { options in
                options.message(1) { encoding in
                    encoding.varint(1, hexadecimalEncoding)
                    encoding.varint(2, codeLength)
                }
                options.varint(3, roleInput)
            }
        }
    }

    static func configuration() -> Data {
        outer { writer in
            writer.message(Field.configuration) { configuration in
                configuration.message(1) { encoding in
                    encoding.varint(1, hexadecimalEncoding)
                    encoding.varint(2, codeLength)
                }
                configuration.varint(2, roleInput)
            }
        }
    }

    static func secret(_ secret: Data) -> Data {
        outer { writer in
            writer.message(Field.secret) { message in
                message.bytes(1, secret)
            }
        }
    }

    private static func outer(_ body: (inout ProtobufWriter) -> Void) -> Data {
        var writer = ProtobufWriter()
        writer.varint(Field.protocolVersion, protocolVersion)
        writer.varint(Field.status, statusOK)
        body(&writer)
        return writer.data
    }
}
