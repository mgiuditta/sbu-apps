import CoreText
import Foundation

/// Bricolage Grotesque ExtraBold, the face of `stat` and `statHero`, bundled with SbuKit.
///
/// Swift packages cannot list fonts in `UIAppFonts`, so SbuKit registers the file from its own
/// bundle the first time a number font is made. Registration is process-wide and happens once.
nonisolated enum SbuFont {
    /// PostScript name of the bundled face, as in the font's name table.
    static let statPostScriptName = "BricolageGrotesque-96ptExtraBold"

    /// The bundled font file.
    static var statFileURL: URL? {
        Bundle.module.url(forResource: "BricolageGrotesque-Bold", withExtension: "ttf")
    }

    /// The SIL Open Font License notice shipped with the font, copyright line first.
    static var licenseURL: URL? {
        Bundle.module.url(forResource: "BricolageGrotesque-OFL", withExtension: "txt")
    }

    /// Whether the bundled face is available to `Font.custom` in this process.
    ///
    /// Reading it registers the font the first time; a font already registered by the host app
    /// counts as available.
    static let isRegistered: Bool = {
        guard let url = statFileURL else { return false }
        var error: Unmanaged<CFError>?
        if CTFontManagerRegisterFontsForURL(url as CFURL, .process, &error) {
            return true
        }
        let code = error.map { CFErrorGetCode($0.takeRetainedValue()) }
        return code == CTFontManagerError.alreadyRegistered.rawValue
    }()
}
