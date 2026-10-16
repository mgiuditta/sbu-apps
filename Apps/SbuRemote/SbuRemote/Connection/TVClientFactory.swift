/// The protocol client for a saved TV.
enum TVClientFactory {
    static func client(for tv: SavedTV) -> any TVClient {
        switch tv.brand {
        case .samsung: SamsungClient(tv: tv)
        case .lg: LGClient(tv: tv)
        case .androidTV: AndroidTVClient(tv: tv)
        case .sony: SonyClient(tv: tv)
        }
    }
}
