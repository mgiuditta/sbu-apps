/// A tag chosen in the search field: only items with it show.
struct TagToken: Identifiable, Hashable {
    let tag: String

    var id: String { tag }
}
