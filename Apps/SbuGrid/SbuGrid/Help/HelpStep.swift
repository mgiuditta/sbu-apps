import Foundation

/// One step of how to draw with the grid, with its symbol.
///
/// DrawinGrid's low reviews say it explains nothing and leaves its terms unexplained: these
/// steps sit in settings, in plain words, in the order you draw.
nonisolated struct HelpStep: Identifiable, Sendable {
    let id: Int
    let systemImage: String
    let text: LocalizedStringResource

    static let all: [HelpStep] = [
        HelpStep(
            id: 1,
            systemImage: "photo",
            text: "Scegli la foto da disegnare: la griglia si stende sopra. Bianco e nero aiuta a vedere luci e ombre."
        ),
        HelpStep(
            id: 2,
            systemImage: "pencil.and.ruler",
            text: "Righi il foglio a matita leggera con le stesse righe e colonne. Se scegli un formato in Foglio, le celle hanno una misura vera: righi quadrati di quella misura."
        ),
        HelpStep(
            id: 3,
            systemImage: "square.grid.3x3",
            text: "Copia una cella alla volta: guarda solo quello che c'è dentro e ridisegnalo nella cella uguale sul foglio. I numeri di righe e colonne ti aiutano a non perderti."
        ),
        HelpStep(
            id: 4,
            systemImage: "camera.viewfinder",
            text: "Con Ricalca metti l'iPhone su un supporto sopra il foglio e segui le linee con la matita guardando lo schermo."
        ),
    ]
}
