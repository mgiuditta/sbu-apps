import Foundation

nonisolated extension Data {
    /// Appends an integer in little-endian byte order, as ZIP headers store them.
    mutating func append<Value: FixedWidthInteger>(le value: Value) {
        Swift.withUnsafeBytes(of: value.littleEndian) { append(contentsOf: $0) }
    }

    /// Reads a little-endian integer at a byte offset from the start, or `nil` past the end.
    func readLE<Value: FixedWidthInteger>(_: Value.Type, at offset: Int) -> Value? {
        let size = MemoryLayout<Value>.size
        guard offset >= 0, offset + size <= count else { return nil }
        var value: Value = 0
        for index in 0..<size {
            value |= Value(self[startIndex + offset + index]) << (8 * index)
        }
        return value
    }
}
