import SwiftUI

extension EnvironmentValues {
    /// The library thumbnails and players load from; the demo library outside the app.
    @Entry var photoLibrary: any PhotoLibrary = DemoLibrary()
}
