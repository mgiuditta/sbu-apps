import Foundation
import SwiftData
import Testing
import UIKit
@testable import SbuInventory

struct ExportImportTests {
    private let calendar = Calendar(identifier: .gregorian)

    private func photo() throws -> ProcessedPhoto {
        let image = UIGraphicsImageRenderer(size: CGSize(width: 300, height: 200)).image { context in
            UIColor.systemGreen.setFill()
            context.fill(CGRect(x: 0, y: 0, width: 300, height: 200))
        }
        return try #require(PhotoProcessor.process(image))
    }

    /// Casa › Garage with a drill (two photos, a serial, a label), an empty labelled box, and glasses at the top.
    private func filledStore() throws -> ModelContainer {
        let container = try ModelContainer.inventory(inMemory: true)
        let context = container.mainContext
        let house = Folder(name: "Casa")
        let garage = Folder(name: "Garage", parent: house)
        let box = Folder(name: "Scatola vuota", parent: garage)
        [house, garage, box].forEach(context.insert)
        box.code = "BOX-1"
        let serial = FieldDefinition(name: "Numero di serie", kind: .text, order: 0)
        let warranty = FieldDefinition(name: "Garanzia fino al", kind: .date, order: 1)
        let cost = FieldDefinition(name: "Riparazione", kind: .money, order: 2)
        [serial, warranty, cost].forEach(context.insert)

        let drill = Item(name: "Trapano", quantity: 2, folder: garage)
        context.insert(drill)
        drill.unitPrice = Decimal(string: "89.90")
        drill.minimumQuantity = 1
        drill.purchaseDate = calendar.date(from: DateComponents(year: 2024, month: 6, day: 1, hour: 12))
        drill.tags = ["attrezzi"]
        drill.notes = "Con valigetta"
        drill.code = "8001234567890"
        for order in 0..<2 {
            let processed = try photo()
            let itemPhoto = ItemPhoto(data: processed.data, thumbnail: processed.thumbnail, order: order)
            context.insert(itemPhoto)
            itemPhoto.item = drill
        }
        let serialValue = FieldValue(definition: serial, item: drill)
        serialValue.text = "SN-42"
        let warrantyValue = FieldValue(definition: warranty, item: drill)
        warrantyValue.date = calendar.date(from: DateComponents(year: 2026, month: 6, day: 1, hour: 12))
        let costValue = FieldValue(definition: cost, item: drill)
        costValue.number = Decimal(string: "15.5")
        [serialValue, warrantyValue, costValue].forEach(context.insert)
        drill.refreshSearchKey()

        let glasses = Item(name: "Bicchieri", quantity: 12)
        context.insert(glasses)
        try context.save()
        return container
    }

    @Test func archiveRoundTripRebuildsTheWholeInventory() throws {
        let source = try filledStore()
        let directory = URL.temporaryDirectory.appending(path: UUID().uuidString)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: directory) }
        let url = try InventoryExport.writeArchive(from: source.mainContext, to: directory, calendar: calendar)
        #expect(url.lastPathComponent.hasPrefix("sbu-inventory-"))
        #expect(url.pathExtension == "zip")

        let file = try ImportFile(data: Data(contentsOf: url), calendar: calendar)
        #expect(file.itemCount == 2)
        #expect(file.photos.count == 2)

        let target = try ModelContainer.inventory(inMemory: true)
        let result = InventoryImport.apply(file, into: target.mainContext, calendar: calendar)
        #expect(result == ImportResult(added: 2, skipped: 0, folders: 3))

        let items = try target.mainContext.fetch(FetchDescriptor<Item>())
        let drill = try #require(items.first { $0.name == "Trapano" })
        let original = try #require(try source.mainContext.fetch(FetchDescriptor<Item>()).first { $0.name == "Trapano" })
        #expect(drill.uuid == original.uuid)
        #expect(drill.quantity == 2)
        #expect(drill.unitPrice == Decimal(string: "89.90"))
        #expect(drill.minimumQuantity == 1)
        #expect(drill.purchaseDate.map { CSVValue.day($0, calendar: calendar) } == "2024-06-01")
        #expect(drill.tags == ["attrezzi"])
        #expect(drill.notes == "Con valigetta")
        #expect(drill.code == "8001234567890")
        #expect(drill.folder?.name == "Garage")
        #expect(drill.folder?.parent?.name == "Casa")
        #expect(drill.sortedPhotos.map(\.data) == original.sortedPhotos.map(\.data))
        let values = Dictionary(uniqueKeysWithValues: drill.sortedFieldValues.map { ($0.definition?.name ?? "", $0) })
        #expect(values["Numero di serie"]?.text == "SN-42")
        #expect(values["Garanzia fino al"]?.date.map { CSVValue.day($0, calendar: calendar) } == "2026-06-01")
        #expect(values["Riparazione"]?.number == Decimal(string: "15.5"))
        #expect(values["Riparazione"]?.definition?.kind == .money)
        #expect(drill.searchKey.contains("sn-42"))

        let box = try #require(try target.mainContext.fetch(FetchDescriptor<Folder>()).first { $0.name == "Scatola vuota" })
        #expect(box.code == "BOX-1")
        #expect(box.parent?.name == "Garage")
        #expect(items.first { $0.name == "Bicchieri" }?.folder == nil)
    }

    @Test func importingTheSameFileAgainAddsNothing() throws {
        let source = try filledStore()
        let directory = URL.temporaryDirectory.appending(path: UUID().uuidString)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: directory) }
        let url = try InventoryExport.writeCSV(from: source.mainContext, to: directory, calendar: calendar)
        let file = try ImportFile(data: Data(contentsOf: url), calendar: calendar)

        let result = InventoryImport.apply(file, into: source.mainContext, calendar: calendar)
        #expect(result == ImportResult(added: 0, skipped: 2, folders: 0))
        #expect(try source.mainContext.fetchCount(FetchDescriptor<Item>()) == 2)
        #expect(try source.mainContext.fetchCount(FetchDescriptor<Folder>()) == 3)
        #expect(try source.mainContext.fetchCount(FetchDescriptor<FieldDefinition>()) == 3)
    }

    @Test func csvWithoutIdsAddsIntoExistingFoldersIgnoringCase() throws {
        let container = try filledStore()
        let file = ImportFile(rows: [InventoryRow(name: "Martello", path: ["casa", "GARAGE"])], photos: [:])
        let result = InventoryImport.apply(file, into: container.mainContext, calendar: calendar)
        #expect(result == ImportResult(added: 1, skipped: 0, folders: 0))
        let hammer = try #require(try container.mainContext.fetch(FetchDescriptor<Item>()).first { $0.name == "Martello" })
        #expect(hammer.folder?.name == "Garage")
    }

    @Test(arguments: [Data(), Data("   \n".utf8)])
    func emptyFileIsUnreadable(data: Data) {
        #expect(throws: ImportFile.Failure.unreadable) { try ImportFile(data: data, calendar: calendar) }
    }

    @Test func archiveWithoutCSVSaysSo() throws {
        let url = URL.temporaryDirectory.appending(path: "\(UUID().uuidString).zip")
        defer { try? FileManager.default.removeItem(at: url) }
        let writer = try ZipWriter(url: url)
        try writer.add("photos/a.heic", data: Data("x".utf8))
        try writer.finish()
        #expect(throws: ImportFile.Failure.noCSV) { try ImportFile(data: Data(contentsOf: url), calendar: calendar) }
    }

    @Test func archiveZippedAgainInAFolderStillFindsItsPhotos() throws {
        let url = URL.temporaryDirectory.appending(path: "\(UUID().uuidString).zip")
        defer { try? FileManager.default.removeItem(at: url) }
        let processed = try photo()
        let writer = try ZipWriter(url: url)
        try writer.add("Inventario/._inventory.csv", data: Data([0, 5, 22, 7]))
        try writer.add("Inventario/inventory.csv", data: Data("nome,foto\nVaso,photos/v.heic\n".utf8))
        try writer.add("Inventario/photos/v.heic", data: processed.data)
        try writer.finish()
        let file = try ImportFile(data: Data(contentsOf: url), calendar: calendar)
        #expect(file.photos["photos/v.heic"] == processed.data)
        #expect(file.rows.map(\.name) == ["Vaso"])
    }
}
