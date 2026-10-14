import Foundation

/// The SF Symbol letter for a name without a category: "Netflix" → `n.circle`. Symbols exist only for a to z.
nonisolated enum Monogram {
    static func systemImage(for name: String) -> String {
        let letter = name.trimmingCharacters(in: .whitespacesAndNewlines).first.map(String.init)?
            .folding(options: [.diacriticInsensitive, .caseInsensitive], locale: Locale(identifier: "en_US_POSIX"))
        guard let letter, letter.count == 1, ("a"..."z").contains(letter) else { return "creditcard" }
        return "\(letter).circle"
    }
}
