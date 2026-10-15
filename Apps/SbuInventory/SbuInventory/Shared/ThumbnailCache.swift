import UIKit

/// Thumbnails already decoded, by photo, so scrolling a long list never decodes the same one twice.
enum ThumbnailCache {
    private static let cache: NSCache<NSUUID, UIImage> = {
        let cache = NSCache<NSUUID, UIImage>()
        cache.countLimit = 500
        return cache
    }()

    static func image(for id: UUID, data: Data?) -> UIImage? {
        if let cached = cache.object(forKey: id as NSUUID) { return cached }
        guard let data, let image = UIImage(data: data) else { return nil }
        cache.setObject(image, forKey: id as NSUUID)
        return image
    }
}
