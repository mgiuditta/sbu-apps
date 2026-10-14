/// Which codes the history shows.
enum HistoryFilter: Hashable {
    case all
    case favorites
    case folder(ScanFolder)

    func includes(_ record: ScanRecord) -> Bool {
        switch self {
        case .all: true
        case .favorites: record.isFavorite
        case let .folder(folder): record.folder == folder
        }
    }
}
