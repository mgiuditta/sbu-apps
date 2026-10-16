import CoreGraphics
import Foundation
import Observation

/// The photo being drawn, its crop to the sheet and the grid over it, kept between launches.
@Observable
final class GridModel {
    /// The photo as chosen, already turned upright and shrunk to a workable size.
    private(set) var photo: CGImage?
    /// The part of the photo the grid covers: the crop, or the whole photo.
    private(set) var picture: CGImage?
    /// Changes with every new photo or crop, so the zoom starts over.
    private(set) var pictureID = UUID()
    /// While a chosen photo downloads from iCloud or decodes.
    private(set) var isOpening = false
    /// Why the last photo did not open, until the alert is dismissed.
    var openError: PhotoError?

    /// Whether the alert about the last photo is showing; dismissing it forgets the error.
    var isShowingOpenError: Bool {
        get { openError != nil }
        set {
            if newValue == false {
                openError = nil
            }
        }
    }

    var settings: GridSettings {
        didSet { saveState() }
    }

    /// The sheet: a new shape crops the photo again, centred, to that shape.
    var paper: PaperSettings {
        didSet {
            if paper.aspectRatio != oldValue.aspectRatio, paper.format.isSheet {
                setCrop(CropGeometry.fitted(aspect: paper.aspectRatio, imageSize: photoSize))
            } else {
                saveState()
            }
        }
    }

    /// The crop in unit coordinates; `nil` for the whole photo. Set it with `setCrop(_:)`.
    private(set) var crop: CGRect?

    @ObservationIgnored private let photoStore: PhotoStore?
    @ObservationIgnored private let stateStore: StateStore?

    /// - Parameters:
    ///   - photoStore: Where the photo is kept; `nil` keeps it only while the app runs.
    ///   - stateStore: Where the choices and the crop are kept; `nil` keeps them only while the app runs.
    ///   - photo: A photo to start with instead of the kept one, for previews and tests.
    init(photoStore: PhotoStore? = .standard, stateStore: StateStore? = StateStore(), photo: CGImage? = nil) {
        self.photoStore = photoStore
        self.stateStore = stateStore
        let state = stateStore?.load() ?? GridState()
        settings = state.settings
        paper = state.paper
        crop = state.crop.flatMap(CropGeometry.sanitized)
        self.photo = photo ?? photoStore?.load()
        updatePicture()
    }

    /// The size of the whole photo, in pixels.
    var photoSize: CGSize {
        guard let photo else { return .zero }
        return CGSize(width: photo.width, height: photo.height)
    }

    /// The size of the picture the grid covers, in pixels.
    var pictureSize: CGSize {
        guard let picture else { return .zero }
        return CGSize(width: picture.width, height: picture.height)
    }

    /// Cells from the sheet when there is one, from the grid settings otherwise.
    var cellRule: CellRule {
        paper.cellRule ?? settings.cellRule
    }

    /// The grid on the picture at its pixel size: the counts the figure shows.
    var layout: GridLayout {
        GridLayout(size: pictureSize, rule: cellRule)
    }

    var count: GridCount {
        GridCount(layout)
    }

    /// Opens the data the Photos picker gave; `nil` when it gave none.
    func open(_ data: Data?) async {
        guard let data else {
            openError = .unavailable
            return
        }
        isOpening = true
        defer { isOpening = false }
        do {
            let image = try await Self.decode(data)
            show(image)
            if let photoStore {
                await Self.keep(image, in: photoStore)
            }
        } catch {
            openError = error as? PhotoError ?? .unreadable
        }
    }

    /// Shows a photo already decoded, such as the demo one, without keeping it; a sheet crops it
    /// at once, centred.
    func show(_ image: CGImage) {
        photo = image
        setCrop(paper.format.isSheet ? CropGeometry.fitted(aspect: paper.aspectRatio, imageSize: photoSize) : nil)
    }

    /// Crops the photo to `rect`, in unit coordinates; `nil` or a rectangle that makes no sense
    /// shows the whole photo.
    func setCrop(_ rect: CGRect?) {
        crop = rect.flatMap(CropGeometry.sanitized)
        updatePicture()
        saveState()
    }

    private func updatePicture() {
        pictureID = UUID()
        guard let photo else {
            picture = nil
            return
        }
        guard let crop else {
            picture = photo
            return
        }
        // Cropping shares the photo's pixels: it costs nothing.
        picture = photo.cropping(to: CropGeometry.pixelRect(crop, imageSize: photoSize)) ?? photo
    }

    private func saveState() {
        stateStore?.save(GridState(settings: settings, paper: paper, crop: crop))
    }

    @concurrent
    private static func decode(_ data: Data) async throws -> CGImage {
        try PhotoDecoder.image(from: data)
    }

    /// A photo that cannot be kept is still shown: it is only lost at the next launch.
    @concurrent
    private static func keep(_ image: CGImage, in store: PhotoStore) async {
        try? store.save(image)
    }
}
