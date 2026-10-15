import Foundation
import SwiftData

extension ModelContainer {
    /// The cover's local store. Never mirrored to iCloud: only the conversation travels (ADR-0011).
    static func duo(inMemory: Bool = false) throws -> ModelContainer {
        try ModelContainer(for: Gift.self, configurations: ModelConfiguration(isStoredInMemoryOnly: inMemory, cloudKitDatabase: .none))
    }

    /// An in-memory store with a few made-up gifts, for previews and screenshots.
    static let duoPreview: ModelContainer = {
        // ponytail: a preview store that fails to open is a programming error.
        let container = try! duo(inMemory: true)
        let context = container.mainContext
        context.insert(Gift(person: "Giulia", idea: "Libro di ricette", price: 28, occasion: .now.addingTimeInterval(86_400 * 12)))
        context.insert(Gift(person: "Marco", idea: "Cuffie", price: 79.90))
        context.insert(Gift(person: "Mamma", idea: "Sciarpa di lana", price: 35, isBought: true))
        return container
    }()
}
