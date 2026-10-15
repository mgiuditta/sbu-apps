import Foundation

/// The chat's name from the exported file's name.
///
/// WhatsApp names exports "WhatsApp Chat - Anna.zip" on iPhone and "WhatsApp Chat with Anna.txt"
/// on Android, translated with the phone's language: the prefix goes, the name stays.
nonisolated enum ChatTitle {
    /// The name in `fileName`, or `nil` when the file says nothing (`_chat.txt`).
    static func title(fromFileName fileName: String) -> String? {
        // A hidden file such as ".txt" has no name, only an extension.
        guard !fileName.hasPrefix(".") else { return nil }
        var name = (fileName as NSString).deletingPathExtension
        // Files shared twice get " 2" or "(1)" from iOS.
        name = name.replacing(/\s*\(\d+\)$/, with: "")
        for prefix in prefixes {
            if let range = name.range(of: prefix, options: [.anchored, .caseInsensitive, .diacriticInsensitive]) {
                name = String(name[range.upperBound...])
                break
            }
        }
        name = name.trimmingCharacters(in: .whitespacesAndNewlines.union(CharacterSet(charactersIn: "-–_")))
        guard !name.isEmpty, name != "chat", name != "_chat" else { return nil }
        return name
    }

    /// Longest first, so "WhatsApp Chat with" wins over "WhatsApp Chat".
    private static let prefixes: [String] = [
        "WhatsApp Chat with", "WhatsApp Chat -", "WhatsApp Chat",
        "Chat WhatsApp con", "Chat di WhatsApp con", "Chat de WhatsApp con", "Chat WhatsApp -", "Chat WhatsApp",
        "WhatsApp-Chat mit", "WhatsApp Chat mit", "Discussion WhatsApp avec", "Conversa do WhatsApp com",
        "WhatsApp-chat met",
    ].sorted { $0.count > $1.count }
}
