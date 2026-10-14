/// A row of the 1.x `scan_history` table, as written: a code read or one made in the 1.x creator.
nonisolated struct LegacyScan: Equatable, Sendable {
    var id: Int
    var data: String
    /// expo-camera's type for a code read (`qr`, `ean13`, `upc_e`), the creator's name for one made.
    var codeType: String
    /// UTC `toISOString()`, such as `2026-10-01T09:30:00.000Z`.
    var scannedAt: String
    var folderID: Int?
    /// bwip-js's name (`qrcode`, `azteccode`), or null for codes read before 1.1.
    var symbology: String?
}
