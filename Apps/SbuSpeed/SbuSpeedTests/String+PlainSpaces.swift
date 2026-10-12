import Foundation

extension String {
    /// Formatters may put a no-break or narrow no-break space between number and unit.
    var withPlainSpaces: String {
        replacing("\u{00A0}", with: " ").replacing("\u{202F}", with: " ")
    }
}
