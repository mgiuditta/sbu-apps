import CoreGraphics
import Foundation
import Observation

/// The photo being drawn and the grid over it, kept between launches.
@Observable
final class GridModel {
    /// The photo as chosen, already turned upright and shrunk to a workable size.
    private(set) var photo: CGImage?
    /// Changes with every new photo, so zoom and crop start over.
    private(set) var photoID = UUID()
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

    @ObservationIgnored private let photoStore: PhotoStore?
    @ObservationIgnored private let stateStore: StateStore?

    /// - Parameters:
    ///   - photoStore: Where the photo is kept; `nil` keeps it only while the app runs.
    ///   - stateStore: Where the grid choices are kept; `nil` keeps them only while the app runs.
    ///   - photo: A photo to start with instead of the kept one, for previews and tests.
    init(photoStore: PhotoStore? = .standard, stateStore: StateStore? = StateStore(), photo: CGImage? = nil) {
        self.photoStore = photoStore
        self.stateStore = stateStore
        let state = stateStore?.load() ?? GridState()
        settings = state.settings
        self.photo = photo ?? photoStore?.load()
    }

    /// The size of the picture the grid covers, in pixels.
    var pictureSize: CGSize {
        guard let photo else { return .zero }
        return CGSize(width: photo.width, height: photo.height)
    }

    var cellRule: CellRule {
        settings.cellRule
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

    /// Shows a photo already decoded, such as the demo one, without keeping it.
    func show(_ image: CGImage) {
        photo = image
        photoID = UUID()
    }

    private func saveState() {
        stateStore?.save(GridState(settings: settings))
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
