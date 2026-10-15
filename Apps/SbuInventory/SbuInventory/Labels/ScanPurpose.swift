import SwiftUI

/// Why a label is being read: to open what it belongs to, or to put it on an item or a box.
enum ScanPurpose {
    case find
    case link

    var title: LocalizedStringKey {
        switch self {
        case .find: "Trova dall'etichetta"
        case .link: "Collega un'etichetta"
        }
    }

    var confirmTitle: LocalizedStringKey {
        switch self {
        case .find: "Cerca"
        case .link: "Collega"
        }
    }
}
