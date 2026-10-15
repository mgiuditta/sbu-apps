import Foundation
import SwiftData

/// Finds what a scanned label belongs to, and moves a label to a new item or folder.
///
/// A code opens one thing only: linking it takes it away from whatever had it before.
enum LabelLinker {
    /// What a label is linked to.
    enum Owner: Equatable {
        case item(Item)
        case folder(Folder)
    }

    /// A code as stored: no spaces or line breaks around it; `nil` when nothing is left.
    nonisolated static func normalized(_ code: String) -> String? {
        let trimmed = code.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }

    static func owner(of code: String, in context: ModelContext) -> Owner? {
        guard let code = normalized(code) else { return nil }
        if let item = try? context.fetch(FetchDescriptor<Item>(predicate: #Predicate { $0.code == code })).first {
            return .item(item)
        }
        if let folder = try? context.fetch(FetchDescriptor<Folder>(predicate: #Predicate { $0.code == code })).first {
            return .folder(folder)
        }
        return nil
    }

    /// Gives the code to `owner`, taking it from every other item and folder.
    static func link(_ code: String, to owner: Owner, in context: ModelContext) {
        guard let code = normalized(code) else { return }
        release(code, in: context)
        switch owner {
        case let .item(item):
            item.code = code
            item.refreshSearchKey()
        case let .folder(folder):
            folder.code = code
        }
    }

    /// Takes the code from every item and folder that has it.
    static func release(_ code: String, in context: ModelContext) {
        let items = (try? context.fetch(FetchDescriptor<Item>(predicate: #Predicate { $0.code == code }))) ?? []
        for item in items {
            item.code = nil
            item.refreshSearchKey()
        }
        let folders = (try? context.fetch(FetchDescriptor<Folder>(predicate: #Predicate { $0.code == code }))) ?? []
        for folder in folders {
            folder.code = nil
        }
    }
}
