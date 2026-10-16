/// How to turn the text the TV has into the text the user typed, for protocols that only
/// insert and delete at the end (LG's IME): delete some characters, then insert the rest.
nonisolated struct TextEdit: Equatable, Sendable {
    let deleteCount: Int
    let insert: String

    init(from old: String, to new: String) {
        let common = zip(old, new).prefix { $0 == $1 }.count
        deleteCount = old.count - common
        insert = String(new.dropFirst(common))
    }

    var isEmpty: Bool { deleteCount == 0 && insert.isEmpty }
}
