import Foundation

nonisolated extension Int64 {
    /// A size on disk as iOS writes it in Settings, such as "18,8 MB" or "1,26 GB", in decimal
    /// units; zero is "0 MB", never "Zero kB".
    var sizeText: String {
        sizeText(locale: .current)
    }

    func sizeText(locale: Locale) -> String {
        guard self > 0 else {
            return "\(0.formatted(.number.locale(locale))) MB"
        }
        return formatted(.byteCount(style: .file).locale(locale))
    }
}
