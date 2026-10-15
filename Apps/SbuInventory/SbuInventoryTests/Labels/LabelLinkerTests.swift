import Foundation
import SwiftData
import Testing
@testable import SbuInventory

struct LabelLinkerTests {
    @Test func scannedCodeFindsTheItemOrTheBox() throws {
        let container = try ModelContainer.inventory(inMemory: true)
        let context = container.mainContext
        let box = Folder(name: "Scatola 3")
        let drill = Item(name: "Trapano")
        context.insert(box)
        context.insert(drill)
        LabelLinker.link(" 8001234567890\n", to: .item(drill), in: context)
        LabelLinker.link("BOX-3", to: .folder(box), in: context)
        try context.save()

        #expect(drill.code == "8001234567890")
        #expect(LabelLinker.owner(of: "8001234567890", in: context) == .item(drill))
        #expect(LabelLinker.owner(of: "BOX-3", in: context) == .folder(box))
        #expect(LabelLinker.owner(of: "unknown", in: context) == nil)
        #expect(LabelLinker.owner(of: "  ", in: context) == nil)
    }

    @Test func linkingACodeTakesItFromItsPreviousOwner() throws {
        let container = try ModelContainer.inventory(inMemory: true)
        let context = container.mainContext
        let box = Folder(name: "Scatola 3")
        let drill = Item(name: "Trapano")
        context.insert(box)
        context.insert(drill)
        LabelLinker.link("A1", to: .item(drill), in: context)
        LabelLinker.link("A1", to: .folder(box), in: context)
        try context.save()

        #expect(drill.code == nil)
        #expect(!drill.searchKey.contains("a1"))
        #expect(box.code == "A1")
        #expect(LabelLinker.owner(of: "A1", in: context) == .folder(box))
    }

    @Test func codeIsPartOfTheSearchKey() throws {
        let container = try ModelContainer.inventory(inMemory: true)
        let context = container.mainContext
        let drill = Item(name: "Trapano")
        context.insert(drill)
        LabelLinker.link("QR-77", to: .item(drill), in: context)
        #expect(SearchQuery("qr-77").matches(drill.searchKey))
    }
}
