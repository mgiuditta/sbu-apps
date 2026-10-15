import Foundation

/// The CRC-32 of ZIP (IEEE 802.3, reflected), updated chunk by chunk.
nonisolated struct CRC32: Sendable {
    private static let table: [UInt32] = (0 ..< 256).map { index in
        var value = UInt32(index)
        for _ in 0 ..< 8 {
            value = value & 1 == 1 ? 0xEDB8_8320 ^ (value >> 1) : value >> 1
        }
        return value
    }

    private var state: UInt32 = 0xFFFF_FFFF

    /// The checksum of the bytes so far.
    var value: UInt32 { state ^ 0xFFFF_FFFF }

    mutating func update(_ data: Data) {
        var crc = state
        data.withUnsafeBytes { buffer in
            for byte in buffer {
                crc = Self.table[Int((crc ^ UInt32(byte)) & 0xFF)] ^ (crc >> 8)
            }
        }
        state = crc
    }
}
