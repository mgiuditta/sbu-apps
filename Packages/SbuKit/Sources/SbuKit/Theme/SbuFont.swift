import CoreText
import Foundation

/// The two faces SbuKit bundles: Bricolage Grotesque, variable on weight, width and optical size,
/// for figures and screen titles; IBM Plex Mono Medium for the cartiglio and metadata.
///
/// Swift packages cannot list fonts in `UIAppFonts`, so SbuKit registers the files from its own
/// bundle the first time a font is made. Registration is process-wide and happens once.
nonisolated enum SbuFont {
    /// PostScript name of the default instance of the variable face (opsz 96, wght 800, wdth 100).
    static let statPostScriptName = "BricolageGrotesque-96ptExtraBold"
    /// PostScript name of the cartiglio face.
    static let monoPostScriptName = "IBMPlexMono-Medium"

    /// Variation axis tags of Bricolage Grotesque, as four-character codes.
    enum Axis {
        static let weight = 0x7767_6874 // 'wght'
        static let width = 0x7764_7468 // 'wdth'
        static let opticalSize = 0x6F70_737A // 'opsz'
    }

    /// The optical sizes the face is drawn for: `opsz` follows the point size inside this range.
    static let opticalSizes: ClosedRange<CGFloat> = 12...96

    /// The bundled variable font file.
    static var statFileURL: URL? {
        Bundle.module.url(forResource: "BricolageGrotesque-Variable", withExtension: "ttf")
    }

    /// The bundled cartiglio font file.
    static var monoFileURL: URL? {
        Bundle.module.url(forResource: "IBMPlexMono-Medium", withExtension: "ttf")
    }

    /// The SIL Open Font License notice of Bricolage Grotesque, copyright line first.
    static var licenseURL: URL? {
        Bundle.module.url(forResource: "BricolageGrotesque-OFL", withExtension: "txt")
    }

    /// The SIL Open Font License notice of IBM Plex Mono, copyright line first.
    static var monoLicenseURL: URL? {
        Bundle.module.url(forResource: "IBMPlexMono-OFL", withExtension: "txt")
    }

    /// Whether both bundled faces are available to `Font.custom` in this process.
    ///
    /// Reading it registers the fonts the first time; a font already registered by the host app
    /// counts as available.
    static let isRegistered: Bool = [statFileURL, monoFileURL].allSatisfy(register)

    /// Bricolage Grotesque ExtraBold at a point size and width, with tabular figures and the
    /// optical size that matches the point size.
    /// - Parameters:
    ///   - size: The point size.
    ///   - width: The `wdth` axis value, 75 (narrow) to 100 (normal).
    static func figure(size: CGFloat, width: CGFloat) -> CTFont {
        _ = isRegistered
        let variation: [Int: CGFloat] = [
            Axis.weight: 800,
            Axis.width: width,
            Axis.opticalSize: min(max(size, opticalSizes.lowerBound), opticalSizes.upperBound),
        ]
        let tabular: [CFString: Int] = [
            kCTFontFeatureTypeIdentifierKey: kNumberSpacingType,
            kCTFontFeatureSelectorIdentifierKey: kMonospacedNumbersSelector,
        ]
        let attributes: [CFString: Any] = [
            kCTFontNameAttribute: statPostScriptName,
            kCTFontVariationAttribute: variation,
            kCTFontFeatureSettingsAttribute: [tabular],
        ]
        return CTFontCreateWithFontDescriptor(CTFontDescriptorCreateWithAttributes(attributes as CFDictionary), size, nil)
    }

    private static func register(_ url: URL?) -> Bool {
        guard let url else { return false }
        var error: Unmanaged<CFError>?
        if CTFontManagerRegisterFontsForURL(url as CFURL, .process, &error) {
            return true
        }
        let code = error.map { CFErrorGetCode($0.takeRetainedValue()) }
        return code == CTFontManagerError.alreadyRegistered.rawValue
    }
}
