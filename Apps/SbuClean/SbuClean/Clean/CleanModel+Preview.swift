import Foundation

extension CleanModel {
    /// A model on the demo library with its own state, for previews.
    static var preview: CleanModel {
        preview(access: .full)
    }

    static func preview(access: LibraryAccess) -> CleanModel {
        let directory = URL.temporaryDirectory.appending(path: "preview-\(UUID().uuidString)", directoryHint: .isDirectory)
        return CleanModel(library: DemoLibrary(access: access), directory: directory, readStorage: {
            DeviceStorage(totalBytes: 128_000_000_000, availableBytes: 21_400_000_000)
        })
    }
}
