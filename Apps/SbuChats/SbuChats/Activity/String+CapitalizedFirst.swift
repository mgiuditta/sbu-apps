extension String {
    /// The text with its first letter in upper case: "alle 21" becomes "Alle 21" at the start of a line.
    var capitalizedFirst: String {
        prefix(1).uppercased() + dropFirst()
    }
}
