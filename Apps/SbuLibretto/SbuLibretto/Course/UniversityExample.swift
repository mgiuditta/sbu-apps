import SwiftUI

/// How one university computes the base, as an example to copy into Settings by hand: not a preset,
/// because the rules change by course and by year. From the regulations in `research/apps/libretto.md`.
struct UniversityExample: Identifiable {
    let id: String
    let name: LocalizedStringKey
    let rule: LocalizedStringKey
    let settings: LocalizedStringKey

    static let all: [UniversityExample] = [
        UniversityExample(
            id: "unimi",
            name: "Università degli Studi di Milano",
            rule: "Facoltà di Scienze politiche, economiche e sociali: media pesata × 110/30, la lode vale 33. +1 per Erasmus o tesi all'estero, +3 se ti laurei in corso nella sessione estiva o autunnale.",
            settings: "Lode 33, conversione × 110/30, bonus 1 o 3."
        ),
        UniversityExample(
            id: "polimi",
            name: "Politecnico di Milano",
            rule: "Media pesata in centodecimi senza lodi, più il punteggio della commissione; la somma si arrotonda all'intero, 0,50 per eccesso, fino a 110.",
            settings: "Lode 30, conversione × 110/30, bonus pari ai punti della commissione, arrotondamento all'intero."
        ),
        UniversityExample(
            id: "unibo",
            name: "Università di Bologna",
            rule: "Ingegneria Elettronica: idoneità escluse, lode 30, media × 110/30, poi × 1,0325 se ti laurei in corso, × 1,016 al primo anno fuori corso.",
            settings: "Lode 30, conversione × 110/30, moltiplicatore 1,0325 o 1,016."
        ),
        UniversityExample(
            id: "sapienza",
            name: "Sapienza Università di Roma",
            rule: "Ingegneria Civile triennale: media pesata × 4, la lode vale 31. Il 110 e lode richiede almeno 115 dagli esami.",
            settings: "Lode 31, conversione × 4. La base mostra anche quanto fanno gli esami oltre il 110."
        ),
    ]
}
