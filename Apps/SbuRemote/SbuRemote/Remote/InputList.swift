import Foundation

/// The TV's inputs, as the source sheet shows them once.
struct InputList: Identifiable {
    let id = UUID()
    let items: [TVShortcut]
}
