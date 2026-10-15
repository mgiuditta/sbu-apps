/// The name alert that is open: a new folder inside a parent, or a new name for a folder.
enum FolderNaming: Identifiable {
    case create(parent: Folder?)
    case rename(Folder)

    var id: String {
        switch self {
        case let .create(parent): "create-\(parent?.uuid.uuidString ?? "top")"
        case let .rename(folder): "rename-\(folder.uuid.uuidString)"
        }
    }
}
