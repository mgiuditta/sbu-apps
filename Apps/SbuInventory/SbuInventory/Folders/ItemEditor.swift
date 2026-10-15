import Foundation

/// The item form to open: a new item in a folder, maybe with a scanned label already on it, or an existing one.
struct ItemEditor: Identifiable {
    enum Mode {
        case new(folder: Folder?, code: String?)
        case edit(Item)
    }

    let id = UUID()
    let mode: Mode
}
