import Foundation
import SwiftData
import Testing
@testable import SbuInventory

struct ItemDraftTests {
    private func photo(_ byte: UInt8) -> PhotoDraft {
        PhotoDraft(id: UUID(), data: Data([byte]), thumbnail: Data([byte]))
    }

    @Test func newItemTakesEveryValueOfTheDraft() throws {
        let container = try ModelContainer.inventory(inMemory: true)
        let context = container.mainContext
        let garage = Folder(name: "Garage")
        let serial = FieldDefinition(name: "Numero di serie", kind: .text, order: 0)
        let warranty = FieldDefinition(name: "Garanzia", kind: .date, order: 1)
        context.insert(garage)
        context.insert(serial)
        context.insert(warranty)

        var draft = ItemDraft(folder: garage, code: " 800123 ")
        draft.name = "  Trapano "
        draft.quantity = 3
        draft.minimumQuantity = 1
        draft.unitPrice = Decimal(string: "89.9")
        draft.addTag("attrezzi")
        draft.addTag(" Attrezzi ")
        draft.photos = [photo(1), photo(2)]
        draft.fields[serial.uuid] = FieldEntry(text: "SN-1")
        draft.fields[warranty.uuid] = FieldEntry()
        #expect(draft.canSave)

        let item = Item(name: "")
        context.insert(item)
        draft.apply(to: item, definitions: [serial, warranty], context: context)
        try context.save()

        #expect(item.name == "Trapano")
        #expect(item.quantity == 3)
        #expect(item.folder == garage)
        #expect(item.tags == ["attrezzi"])
        #expect(item.code == "800123")
        #expect(item.sortedPhotos.map(\.data) == [Data([1]), Data([2])])
        #expect(item.sortedFieldValues.map(\.text) == ["SN-1"])
        #expect(SearchQuery("sn-1 attrezzi 800123").matches(item.searchKey))
    }

    @Test func editingReordersRemovesPhotosAndClearsEmptiedFields() throws {
        let container = try ModelContainer.inventory(inMemory: true)
        let context = container.mainContext
        let serial = FieldDefinition(name: "Numero di serie", kind: .text, order: 0)
        context.insert(serial)
        let item = Item(name: "Trapano")
        context.insert(item)
        var draft = ItemDraft(item: item)
        draft.photos = [photo(1), photo(2), photo(3)]
        draft.fields[serial.uuid] = FieldEntry(text: "SN-1")
        draft.apply(to: item, definitions: [serial], context: context)
        try context.save()

        var edit = ItemDraft(item: item)
        #expect(edit.photos.count == 3)
        #expect(edit.fields[serial.uuid]?.text == "SN-1")
        edit.photos = [edit.photos[2], edit.photos[0]]
        edit.fields[serial.uuid] = FieldEntry(text: "  ")
        edit.code = nil
        edit.apply(to: item, definitions: [serial], context: context)
        try context.save()

        #expect(item.sortedPhotos.map(\.data) == [Data([3]), Data([1])])
        #expect(try context.fetchCount(FetchDescriptor<ItemPhoto>()) == 2)
        #expect(item.sortedFieldValues.isEmpty)
        #expect(try context.fetchCount(FetchDescriptor<FieldValue>()) == 0)
    }

    @Test func blankNameCannotBeSaved() {
        var draft = ItemDraft(folder: nil)
        draft.name = "   "
        #expect(!draft.canSave)
    }

    @Test func deletingAFolderTakesEverythingInsideWithIt() throws {
        let container = try ModelContainer.inventory(inMemory: true)
        let context = container.mainContext
        let house = Folder(name: "Casa")
        let garage = Folder(name: "Garage", parent: house)
        context.insert(house)
        context.insert(garage)
        let drill = Item(name: "Trapano", folder: garage)
        context.insert(drill)
        let photo = ItemPhoto(data: Data([1]), thumbnail: Data([1]), order: 0)
        context.insert(photo)
        photo.item = drill
        let kept = Item(name: "Bicchieri")
        context.insert(kept)
        try context.save()

        InventoryActions.delete(house, context: context)
        #expect(try context.fetchCount(FetchDescriptor<Folder>()) == 0)
        #expect(try context.fetch(FetchDescriptor<Item>()).map(\.name) == ["Bicchieri"])
        #expect(try context.fetchCount(FetchDescriptor<ItemPhoto>()) == 0)
    }

    @Test func folderNeverMovesIntoItsOwnInside() throws {
        let container = try ModelContainer.inventory(inMemory: true)
        let context = container.mainContext
        let house = Folder(name: "Casa")
        let garage = Folder(name: "Garage", parent: house)
        context.insert(house)
        context.insert(garage)
        InventoryActions.move(house, to: garage, context: context)
        #expect(house.parent == nil)
        InventoryActions.move(garage, to: nil, context: context)
        #expect(garage.parent == nil)
    }

    @Test func blankFolderNameCreatesNothing() throws {
        let container = try ModelContainer.inventory(inMemory: true)
        #expect(InventoryActions.createFolder(named: "  ", in: nil, context: container.mainContext) == nil)
        #expect(InventoryActions.createFolder(named: " Garage ", in: nil, context: container.mainContext)?.name == "Garage")
    }
}
