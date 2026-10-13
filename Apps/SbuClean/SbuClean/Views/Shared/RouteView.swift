import SwiftUI

/// The screen for a route.
struct RouteView: View {
    let route: Route
    let model: CleanModel

    var body: some View {
        switch route {
        case .swipe(let source): SwipeScreen(model: model, source: source)
        case .months: MonthsScreen(model: model)
        case .albums: AlbumsScreen(model: model)
        case .duplicates: DuplicatesScreen(model: model)
        case .groups(let kind): GroupListScreen(model: model, kind: kind)
        case .grid(let category): MediaGridScreen(model: model, category: category)
        case .videos: VideosScreen(model: model)
        case .livePhotos: LivePhotosScreen(model: model)
        case .compress(let id): CompressScreen(model: model, id: id)
        case .bin: BinScreen(model: model)
        case .keepForever: KeepForeverScreen(model: model)
        case .stats: StatsScreen(model: model)
        }
    }
}
