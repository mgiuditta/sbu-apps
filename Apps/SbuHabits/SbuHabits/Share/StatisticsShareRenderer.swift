import ImageIO
import SbuKit
import SwiftUI
import UniformTypeIdentifiers

/// Turns a `StatisticsShare` into the picture that is shared, on the device, only when the share
/// sheet asks for it.
///
/// The picture is always light and at the default text size, whatever the phone's settings:
/// it is paper that leaves the app, seen on other screens in other modes, and its layout is
/// fixed, so a large text size would push the charts out of the frame. The app itself still
/// follows both.
enum StatisticsShareRenderer {
    /// The picture of `share`, `StatisticsShareImage.size` at `StatisticsShareImage.scale`.
    static func image(of share: StatisticsShare) -> UIImage? {
        let renderer = ImageRenderer(content: content(of: share))
        renderer.proposedSize = ProposedViewSize(StatisticsShareImage.size)
        renderer.scale = StatisticsShareImage.scale
        renderer.isOpaque = true
        return renderer.uiImage
    }

    /// The picture as PNG, with what it shows written as its description.
    static func png(of share: StatisticsShare) -> Data? {
        guard let image = image(of: share)?.cgImage else { return nil }
        let data = NSMutableData()
        guard let destination = CGImageDestinationCreateWithData(data, UTType.png.identifier as CFString, 1, nil) else { return nil }
        let properties = [
            kCGImagePropertyPNGDictionary: [
                kCGImagePropertyPNGTitle: share.title(),
                kCGImagePropertyPNGDescription: share.imageDescription(),
            ],
        ] as CFDictionary
        CGImageDestinationAddImage(destination, image, properties)
        guard CGImageDestinationFinalize(destination) else { return nil }
        return data as Data
    }

    private static func content(of share: StatisticsShare) -> some View {
        StatisticsShareImage(share: share)
            .tint(SbuTheme.ink)
            .environment(\.colorScheme, .light)
            .environment(\.dynamicTypeSize, .large)
    }
}
