import CloudKit
import UIKit

/// Shows the system iCloud sharing screen for a habit already shared, or just made shareable:
/// invite people, see who has it, stop sharing. `UICloudSharingController(share:container:)` is
/// the one API that does all three on iOS 17, and is presented from UIKit, over the sheet the
/// form is in, as it expects.
final class CloudSharingPresenter: NSObject, UICloudSharingControllerDelegate {
    /// The presenter on screen: the controller keeps its delegate weakly.
    private static var current: CloudSharingPresenter?

    private let title: String
    private let didChange: (_ stopped: Bool) -> Void

    private init(title: String, didChange: @escaping (_ stopped: Bool) -> Void) {
        self.title = title
        self.didChange = didChange
    }

    /// - Parameter didChange: Called when people are invited or removed, or sharing stops.
    static func present(_ share: CKShare, title: String, didChange: @escaping (_ stopped: Bool) -> Void) {
        guard let presenter = topViewController() else { return }
        let delegate = CloudSharingPresenter(title: title, didChange: didChange)
        let controller = UICloudSharingController(share: share, container: CKContainer(identifier: CloudKitSharedHabits.containerIdentifier))
        // Read only, and only with the people invited: never a public link.
        controller.availablePermissions = [.allowPrivate, .allowReadOnly]
        controller.delegate = delegate
        current = delegate
        presenter.present(controller, animated: true)
    }

    func itemTitle(for csc: UICloudSharingController) -> String? {
        title
    }

    func cloudSharingController(_ csc: UICloudSharingController, failedToSaveShareWithError error: any Error) {
        didChange(false)
    }

    func cloudSharingControllerDidSaveShare(_ csc: UICloudSharingController) {
        didChange(false)
    }

    func cloudSharingControllerDidStopSharing(_ csc: UICloudSharingController) {
        didChange(true)
    }

    private static func topViewController() -> UIViewController? {
        let scene = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first { $0.activationState == .foregroundActive }
        var controller = scene?.keyWindow?.rootViewController
        while let presented = controller?.presentedViewController {
            controller = presented
        }
        return controller
    }
}
