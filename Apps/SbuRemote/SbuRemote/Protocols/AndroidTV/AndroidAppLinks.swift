/// Android TV gives no list of installed apps, so the shortcuts are a short fixed list of the
/// services' public web addresses, which Android opens in their app (#351). Text only, no logos.
/// A link that stops working is removed here; nothing is fetched to keep it up to date.
nonisolated enum AndroidAppLinks {
    static let all = [
        TVShortcut(id: "https://www.youtube.com", name: "YouTube"),
        TVShortcut(id: "https://www.netflix.com/title", name: "Netflix"),
        TVShortcut(id: "https://app.primevideo.com", name: "Prime Video"),
        TVShortcut(id: "https://www.disneyplus.com", name: "Disney+"),
        TVShortcut(id: "https://www.raiplay.it", name: "RaiPlay"),
        TVShortcut(id: "https://open.spotify.com", name: "Spotify"),
    ]
}
