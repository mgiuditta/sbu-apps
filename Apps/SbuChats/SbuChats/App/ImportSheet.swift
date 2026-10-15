/// The sheet the import shows: reading, "Chi sei?", or why it failed.
enum ImportSheet: Identifiable, Equatable {
    /// The file is being read; the fraction is in `ChatLibrary.progress`.
    case reading
    /// Pick which sender is you.
    case owner(OwnerRequest)
    /// The file didn't become a chat.
    case failure(ImportFailure)

    var id: String {
        switch self {
        case .reading: "reading"
        case let .owner(request): "owner-\(request.chatID)"
        case .failure: "failure"
        }
    }
}
