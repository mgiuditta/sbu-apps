import SwiftUI
import UIKit

/// The system camera, for one photo of an item. Hands back the photo already shrunk and upright.
struct CameraPicker: UIViewControllerRepresentable {
    let taken: (PhotoDraft) -> Void

    @Environment(\.dismiss) private var dismiss

    /// Whether this iPhone has a camera the app can use; the simulator has none.
    static var isAvailable: Bool {
        UIImagePickerController.isSourceTypeAvailable(.camera)
    }

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.cameraCaptureMode = .photo
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ picker: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    final class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        private let parent: CameraPicker

        init(parent: CameraPicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let image = info[.originalImage] as? UIImage, let processed = PhotoProcessor.process(image) {
                parent.taken(PhotoDraft(id: UUID(), data: processed.data, thumbnail: processed.thumbnail))
            }
            parent.dismiss()
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}
