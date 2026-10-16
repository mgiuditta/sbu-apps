import Foundation

/// A size on disk as iOS writes it in Settings, such as "18,4 MB" or "1,1 GB", in decimal units;
/// zero is "0 MB", never "Zero kB", and a negative size reads as zero.
nonisolated struct SizeFormat: FormatStyle {
    var locale: Locale = .autoupdatingCurrent

    func format(_ value: Int64) -> String {
        guard value > 0 else {
            return "\(0.formatted(.number.locale(locale))) MB"
        }
        return value.formatted(.byteCount(style: .file).locale(locale))
    }

    func locale(_ locale: Locale) -> SizeFormat {
        SizeFormat(locale: locale)
    }
}

nonisolated extension FormatStyle where Self == SizeFormat {
    /// A size on disk, as iOS writes it.
    static var size: SizeFormat { SizeFormat() }
}
