import Foundation

/// What the ranking lists.
enum TermKind: String, CaseIterable, Identifiable {
    case words
    case emoji

    var id: Self { self }

    var title: LocalizedStringResource {
        switch self {
        case .words: "Parole"
        case .emoji: "Emoji"
        }
    }
}
