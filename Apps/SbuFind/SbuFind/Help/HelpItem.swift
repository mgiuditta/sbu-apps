import Foundation

/// One sentence of the help page, with its symbol.
nonisolated struct HelpItem: Identifiable, Sendable {
    let id: Int
    let systemImage: String
    let text: LocalizedStringResource
}
