import SwiftUI

extension SwipeSource {
    /// The navigation title of the queue.
    var title: Text {
        switch self {
        case .recent: Text("Recenti")
        case .random: Text("Casuale")
        case .onThisDay: Text("Accadde oggi")
        case .later: Text("Da decidere dopo")
        case .month(let month): Text(month.firstDay(in: .current), format: .dateTime.month(.wide).year())
        case .album(let album): Text(verbatim: album.title)
        case .category(let category): category.title
        }
    }
}

extension MediaCategory {
    var title: Text {
        switch self {
        case .screenshots: Text("Screenshot")
        case .screenRecordings: Text("Registrazioni")
        case .videos: Text("Video")
        case .livePhotos: Text("Live Photo")
        }
    }
}
