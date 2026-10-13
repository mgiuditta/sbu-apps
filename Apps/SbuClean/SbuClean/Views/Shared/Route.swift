/// Every screen the home opens.
enum Route: Hashable {
    case swipe(SwipeSource)
    case months
    case albums
    case duplicates
    case groups(GroupKind)
    case grid(MediaCategory)
    case videos
    case livePhotos
    case compress(String)
    case bin
    case keepForever
    case stats
}
