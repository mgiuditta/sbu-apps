import Foundation

/// The sheet the drawing goes on: none (the photo as it is), a standard size or a custom one.
nonisolated enum PaperFormat: String, Codable, CaseIterable, Identifiable, Sendable {
    /// No sheet: a free crop, and the grid from columns and rows.
    case free
    case a5
    case a4
    case a3
    case letter
    case custom

    var id: Self { self }

    /// Width and height in portrait, in millimetres; `nil` for none or custom.
    var portraitMillimeters: (width: Double, height: Double)? {
        switch self {
        case .free, .custom: nil
        case .a5: (148, 210)
        case .a4: (210, 297)
        case .a3: (297, 420)
        case .letter: (215.9, 279.4)
        }
    }

    var isSheet: Bool {
        self != .free
    }

    var title: LocalizedStringResource {
        switch self {
        case .free: "Nessuno"
        case .a5: "A5"
        case .a4: "A4"
        case .a3: "A3"
        case .letter: "Letter"
        case .custom: "Personalizzato"
        }
    }
}
