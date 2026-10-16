import PhotosUI
import SwiftUI

extension GridModel {
    /// Opens a photo chosen in the Photos picker. The picker runs outside the app, so Sbu Grid
    /// sees only the photo chosen, never the library, and asks for no permission.
    func open(_ item: PhotosPickerItem) async {
        let data = try? await item.loadTransferable(type: Data.self)
        await open(data ?? nil)
    }
}
