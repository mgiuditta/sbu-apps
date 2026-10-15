/// "Chi sei?" for one chat: its senders, most messages first, and who is you now, if anyone.
struct OwnerRequest: Equatable {
    let chatID: Int64
    let senders: [String]
    var current: String?
    /// After an import the chat opens once you answer; from the chat screen it's already open.
    var opensChat = true
}
