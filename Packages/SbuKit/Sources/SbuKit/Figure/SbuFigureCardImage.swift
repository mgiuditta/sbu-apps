import CoreTransferable
import SwiftUI
import UniformTypeIdentifiers

/// The figure card as a PNG to share, drawn only when the person shares it.
public struct SbuFigureCardImage: Transferable, Sendable {
    let value: String
    let unit: String?
    let word: LocalizedStringResource
    let appName: String
    let accent: SbuAccent

    /// Creates the card for a figure.
    /// - Parameters:
    ///   - value: The figure, already formatted for the locale, as on the tool screen.
    ///   - unit: A unit drawn right after the value, such as `°`; `nil` for none.
    ///   - word: The word under the figure, such as "all'anno" or "giorni di fila".
    ///   - appName: The app's name, such as "Sbu Habits": with `sbu.dev`, the card's signature.
    ///   - accent: The app's accent, for the full stop.
    public init(value: String, unit: String? = nil, word: LocalizedStringResource, appName: String, accent: SbuAccent) {
        self.value = value
        self.unit = unit
        self.word = word
        self.appName = appName
        self.accent = accent
    }

    public static var transferRepresentation: some TransferRepresentation {
        DataRepresentation(exportedContentType: .png) { card in
            try await card.pngData()
        }
        .suggestedFileName { card in card.appName }
    }

    /// The card drawn at 1080 × 1350 pixels, as PNG data.
    @MainActor func pngData() throws -> Data {
        let renderer = ImageRenderer(content: SbuFigureCard(value: value, unit: unit, word: word, appName: appName, accent: accent))
        renderer.scale = SbuFigureCard.scale
        guard let data = renderer.uiImage?.pngData() else { throw CocoaError(.fileWriteUnknown) }
        return data
    }
}
