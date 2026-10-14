import Contacts
import ContactsUI
import SwiftUI

/// The system's new-contact card, filled from the code; the user saves it, so the app needs no access to Contacts.
struct ContactEditor: UIViewControllerRepresentable {
    let card: ContactCard
    @Environment(\.dismiss) private var dismiss

    func makeUIViewController(context: Context) -> UINavigationController {
        let contact = (try? CNContactVCardSerialization.contacts(with: Data(card.vCard.utf8)).first?.mutableCopy() as? CNMutableContact) ?? CNMutableContact()
        let controller = CNContactViewController(forNewContact: contact)
        controller.delegate = context.coordinator
        return UINavigationController(rootViewController: controller)
    }

    func updateUIViewController(_ controller: UINavigationController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator { dismiss() }
    }

    final class Coordinator: NSObject, CNContactViewControllerDelegate {
        private let done: () -> Void

        init(done: @escaping () -> Void) {
            self.done = done
        }

        func contactViewController(_ viewController: CNContactViewController, didCompleteWith contact: CNContact?) {
            done()
        }
    }
}
