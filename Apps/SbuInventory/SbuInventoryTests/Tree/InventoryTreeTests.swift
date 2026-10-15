import Foundation
import Testing
@testable import SbuInventory

struct InventoryTreeTests {
    private let house = UUID()
    private let garage = UUID()
    private let box = UUID()
    private let kitchen = UUID()

    private var folders: [FolderNode] {
        [
            FolderNode(id: house, name: "Casa", parentID: nil),
            FolderNode(id: garage, name: "Garage", parentID: house),
            FolderNode(id: box, name: "Scatola 3", parentID: garage),
            FolderNode(id: kitchen, name: "Cucina", parentID: house),
        ]
    }

    private var items: [ItemNode] {
        [
            ItemNode(id: UUID(), folderID: box, quantity: 1, unitPrice: Decimal(89)),
            ItemNode(id: UUID(), folderID: box, quantity: 6, unitPrice: Decimal(string: "4.5")),
            ItemNode(id: UUID(), folderID: kitchen, quantity: 12),
            ItemNode(id: UUID(), folderID: nil, quantity: 2),
        ]
    }

    @Test func pathGoesFromTheTopDown() {
        let tree = InventoryTree(folders: folders, items: [])
        #expect(tree.path(of: box) == ["Casa", "Garage", "Scatola 3"])
        #expect(tree.path(of: nil).isEmpty)
        #expect(FolderPath.text(tree.path(of: box), root: "Inventario") == "Casa › Garage › Scatola 3")
        #expect(FolderPath.text([], root: "Inventario") == "Inventario")
    }

    @Test func wholeInventoryAddsEveryQuantityAndValue() {
        let total = InventoryTree(folders: folders, items: items).total(in: nil)
        #expect(total.quantity == 21)
        #expect(total.itemCount == 4)
        #expect(total.folderCount == 4)
        #expect(total.value == Decimal(string: "116"))
    }

    @Test func folderTotalCountsEverythingInsideAtAnyDepth() {
        let tree = InventoryTree(folders: folders, items: items)
        #expect(tree.total(in: garage) == InventoryTotal(quantity: 7, itemCount: 2, folderCount: 1, value: Decimal(116)))
        #expect(tree.total(in: house).quantity == 19)
        #expect(tree.total(in: kitchen).value == nil)
    }

    @Test func emptyInventoryIsZeroWithoutValue() {
        #expect(InventoryTree(folders: [], items: []).total(in: nil) == InventoryTotal())
    }

    @Test func negativeQuantitiesNeverLowerTheTotal() {
        let tree = InventoryTree(folders: [], items: [ItemNode(id: UUID(), folderID: nil, quantity: -3, unitPrice: 10)])
        #expect(tree.total(in: nil).quantity == 0)
        #expect(tree.total(in: nil).value == 0)
    }

    @Test func folderNeverMovesIntoItselfOrItsInside() {
        let tree = InventoryTree(folders: folders, items: [])
        #expect(!tree.canMove(folder: garage, into: garage))
        #expect(!tree.canMove(folder: house, into: box))
        #expect(tree.canMove(folder: box, into: kitchen))
        #expect(tree.canMove(folder: box, into: nil))
    }

    @Test func loopsInADamagedStoreNeverHang() {
        let first = UUID(), second = UUID()
        let tree = InventoryTree(folders: [
            FolderNode(id: first, name: "A", parentID: second),
            FolderNode(id: second, name: "B", parentID: first),
        ], items: [ItemNode(id: UUID(), folderID: first, quantity: 3)])
        #expect(tree.path(of: first).count == 2)
        #expect(tree.subtree(of: first) == [first, second])
        #expect(tree.total(in: first).quantity == 3)
    }

    @Test func veryDeepChainIsWalkedWithoutRecursionAndCappedInDepth() {
        var chain: [FolderNode] = []
        var parent: UUID?
        for level in 0..<20_000 {
            let node = FolderNode(id: UUID(), name: "L\(level)", parentID: parent)
            chain.append(node)
            parent = node.id
        }
        let tree = InventoryTree(folders: chain, items: [ItemNode(id: UUID(), folderID: parent, quantity: 1)])
        #expect(tree.path(of: parent).count == InventoryTree.maxDepth)
        let outline = tree.outline()
        #expect(outline.count == InventoryTree.maxDepth)
        #expect(outline.map(\.depth).max() == InventoryTree.maxDepth - 1)
        #expect(tree.total(in: chain[0].id).quantity == 1)
        #expect(tree.subtree(of: chain[0].id).count == 20_000)
    }

    @Test func foldersInALoopNeverReachTheOutlineTwice() {
        let top = UUID(), first = UUID(), second = UUID()
        let tree = InventoryTree(folders: [
            FolderNode(id: top, name: "Casa", parentID: nil),
            FolderNode(id: first, name: "A", parentID: second),
            FolderNode(id: second, name: "B", parentID: first),
            FolderNode(id: UUID(), name: "Self", parentID: nil),
        ], items: [])
        #expect(tree.outline().map(\.folder.name) == ["Casa", "Self"])
        #expect(!tree.canMove(folder: first, into: second))
    }

    @Test func outlineListsFoldersDepthFirstByName() {
        let outline = InventoryTree(folders: folders, items: []).outline()
        #expect(outline.map(\.folder.name) == ["Casa", "Cucina", "Garage", "Scatola 3"])
        #expect(outline.map(\.depth) == [0, 1, 1, 2])
    }

    @Test(arguments: [
        (3, Optional(4), true),
        (4, Optional(4), true),
        (5, Optional(4), false),
        (0, Optional<Int>.none, false),
        (0, Optional(0), true),
    ])
    func lowStockAtOrBelowTheMinimum(quantity: Int, minimum: Int?, isLow: Bool) {
        #expect(LowStock.isLow(quantity: quantity, minimum: minimum) == isLow)
    }
}
