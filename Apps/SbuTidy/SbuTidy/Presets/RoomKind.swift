import Foundation

/// The kinds of room you can add, each with its symbol and its ready-made chores, as Tody's
/// area types: "Base" chores most homes need, "Speciali" for the occasional deep clean.
nonisolated enum RoomKind: String, Codable, CaseIterable, Identifiable, Sendable {
    case kitchen
    case bathroom
    case bedroom
    case livingRoom
    case diningRoom
    case kidsRoom
    case office
    case hallway
    case laundry
    case balcony
    case garden
    case garage
    case wholeHome
    case other

    var id: Self { self }

    var name: LocalizedStringResource {
        switch self {
        case .kitchen: "Cucina"
        case .bathroom: "Bagno"
        case .bedroom: "Camera da letto"
        case .livingRoom: "Soggiorno"
        case .diningRoom: "Sala da pranzo"
        case .kidsRoom: "Cameretta"
        case .office: "Studio"
        case .hallway: "Ingresso"
        case .laundry: "Lavanderia"
        case .balcony: "Balcone"
        case .garden: "Giardino"
        case .garage: "Garage"
        case .wholeHome: "Tutta la casa"
        case .other: "Altra stanza"
        }
    }

    /// SF Symbol of the room, at medium weight like every symbol of the app.
    var symbol: String {
        switch self {
        case .kitchen: "refrigerator"
        case .bathroom: "shower"
        case .bedroom: "bed.double"
        case .livingRoom: "sofa"
        case .diningRoom: "fork.knife"
        case .kidsRoom: "teddybear"
        case .office: "desktopcomputer"
        case .hallway: "door.left.hand.open"
        case .laundry: "washer"
        case .balcony: "sun.max"
        case .garden: "leaf"
        case .garage: "car"
        case .wholeHome: "house"
        case .other: "square.dashed"
        }
    }

    /// Chores most homes need in this room; added with the room unless you say otherwise.
    var basePresets: [ChorePreset] {
        switch self {
        case .kitchen: [
            ChorePreset("Lavare i piatti", every: 1, .day, effort: .medium),
            ChorePreset("Pulire i piani di lavoro", every: 2, .day, effort: .light),
            ChorePreset("Pulire il piano cottura", every: 1, .week, effort: .medium),
            ChorePreset("Lavare il pavimento", every: 1, .week, effort: .medium),
            ChorePreset("Svuotare la spazzatura", every: 3, .day, effort: .light),
            ChorePreset("Pulire il lavello", every: 1, .week, effort: .light),
        ]
        case .bathroom: [
            ChorePreset("Pulire il WC", every: 1, .week, effort: .medium),
            ChorePreset("Pulire il lavandino", every: 1, .week, effort: .light),
            ChorePreset("Pulire la doccia", every: 1, .week, effort: .heavy),
            ChorePreset("Pulire lo specchio", every: 1, .week, effort: .light),
            ChorePreset("Cambiare gli asciugamani", every: 1, .week, effort: .light),
            ChorePreset("Lavare il pavimento", every: 1, .week, effort: .medium),
        ]
        case .bedroom: [
            ChorePreset("Cambiare le lenzuola", every: 1, .week, effort: .medium),
            ChorePreset("Spolverare", every: 2, .week, effort: .light),
            ChorePreset("Passare l'aspirapolvere", every: 1, .week, effort: .medium),
            ChorePreset("Riordinare", every: 3, .day, effort: .light),
        ]
        case .livingRoom: [
            ChorePreset("Spolverare", every: 1, .week, effort: .light),
            ChorePreset("Passare l'aspirapolvere", every: 1, .week, effort: .medium),
            ChorePreset("Riordinare", every: 2, .day, effort: .light),
            ChorePreset("Lavare il pavimento", every: 2, .week, effort: .medium),
        ]
        case .diningRoom: [
            ChorePreset("Pulire il tavolo", every: 1, .day, effort: .light),
            ChorePreset("Passare l'aspirapolvere", every: 1, .week, effort: .medium),
            ChorePreset("Spolverare", every: 2, .week, effort: .light),
        ]
        case .kidsRoom: [
            ChorePreset("Riordinare i giochi", every: 1, .day, effort: .light),
            ChorePreset("Cambiare le lenzuola", every: 1, .week, effort: .medium),
            ChorePreset("Passare l'aspirapolvere", every: 1, .week, effort: .medium),
            ChorePreset("Spolverare", every: 2, .week, effort: .light),
        ]
        case .office: [
            ChorePreset("Riordinare la scrivania", every: 1, .week, effort: .light),
            ChorePreset("Spolverare", every: 2, .week, effort: .light),
            ChorePreset("Passare l'aspirapolvere", every: 2, .week, effort: .medium),
        ]
        case .hallway: [
            ChorePreset("Passare l'aspirapolvere", every: 1, .week, effort: .light),
            ChorePreset("Riordinare le scarpe", every: 1, .week, effort: .light),
            ChorePreset("Lavare il pavimento", every: 2, .week, effort: .medium),
        ]
        case .laundry: [
            ChorePreset("Fare il bucato", every: 3, .day, effort: .medium),
            ChorePreset("Stirare", every: 1, .week, effort: .heavy),
            ChorePreset("Pulire il filtro della lavatrice", every: 1, .month, effort: .light),
        ]
        case .balcony: [
            ChorePreset("Spazzare", every: 2, .week, effort: .light),
            ChorePreset("Annaffiare le piante", every: 2, .day, effort: .light),
        ]
        case .garden: [
            ChorePreset("Tagliare l'erba", every: 2, .week, effort: .heavy),
            ChorePreset("Annaffiare", every: 2, .day, effort: .light),
            ChorePreset("Raccogliere le foglie", every: 1, .week, effort: .medium),
        ]
        case .garage: [
            ChorePreset("Spazzare", every: 1, .month, effort: .medium),
            ChorePreset("Riordinare gli attrezzi", every: 2, .month, effort: .medium),
        ]
        case .wholeHome: [
            ChorePreset("Svuotare i cestini", every: 1, .week, effort: .light),
            ChorePreset("Annaffiare le piante", every: 1, .week, effort: .light),
            ChorePreset("Cambiare l'aria", every: 1, .day, effort: .light),
        ]
        case .other: []
        }
    }

    /// The occasional deep clean, picked one by one.
    var specialPresets: [ChorePreset] {
        switch self {
        case .kitchen: [
            ChorePreset("Pulire il frigorifero", every: 1, .month, effort: .heavy),
            ChorePreset("Pulire il forno", every: 1, .month, effort: .heavy),
            ChorePreset("Sbrinare il congelatore", every: 6, .month, effort: .heavy),
            ChorePreset("Pulire la cappa", every: 2, .month, effort: .medium),
            ChorePreset("Decalcificare il bollitore", every: 2, .month, effort: .light),
            ChorePreset("Pulire il microonde", every: 2, .week, effort: .light),
            ChorePreset("Pulire la lavastoviglie", every: 1, .month, effort: .medium),
        ]
        case .bathroom: [
            ChorePreset("Pulire le fughe", every: 3, .month, effort: .heavy),
            ChorePreset("Lavare la tenda della doccia", every: 2, .month, effort: .medium),
            ChorePreset("Decalcificare i rubinetti", every: 1, .month, effort: .medium),
            ChorePreset("Pulire gli scarichi", every: 1, .month, effort: .medium),
        ]
        case .bedroom, .kidsRoom: [
            ChorePreset("Girare il materasso", every: 3, .month, effort: .heavy),
            ChorePreset("Lavare le tende", every: 6, .month, effort: .heavy),
            ChorePreset("Riordinare l'armadio", every: 3, .month, effort: .heavy),
            ChorePreset("Lavare i cuscini", every: 6, .month, effort: .medium),
        ]
        case .livingRoom, .diningRoom, .office, .hallway: [
            ChorePreset("Pulire i vetri", every: 1, .month, effort: .heavy),
            ChorePreset("Lavare le tende", every: 6, .month, effort: .heavy),
            ChorePreset("Pulire i battiscopa", every: 2, .month, effort: .medium),
            ChorePreset("Pulire i termosifoni", every: 3, .month, effort: .medium),
            ChorePreset("Spolverare le lampade", every: 1, .month, effort: .light),
        ]
        case .laundry: [
            ChorePreset("Lavaggio a vuoto della lavatrice", every: 1, .month, effort: .light),
            ChorePreset("Pulire l'asciugatrice", every: 1, .month, effort: .light),
        ]
        case .balcony, .garden: [
            ChorePreset("Lavare i mobili da esterno", every: 3, .month, effort: .medium),
            ChorePreset("Potare", every: 6, .month, effort: .heavy),
        ]
        case .garage: [
            ChorePreset("Buttare quello che non serve", every: 6, .month, effort: .heavy),
        ]
        case .wholeHome: [
            ChorePreset("Pulire i vetri", every: 1, .month, effort: .heavy),
            ChorePreset("Pulire le porte e le maniglie", every: 1, .month, effort: .medium),
            ChorePreset("Controllare i rilevatori di fumo", every: 6, .month, effort: .light),
            ChorePreset("Pulire i filtri del condizionatore", every: 6, .month, effort: .medium),
        ]
        case .other: [
            ChorePreset("Spolverare", every: 2, .week, effort: .light),
            ChorePreset("Passare l'aspirapolvere", every: 1, .week, effort: .medium),
            ChorePreset("Lavare il pavimento", every: 2, .week, effort: .medium),
            ChorePreset("Riordinare", every: 1, .week, effort: .light),
            ChorePreset("Pulire i vetri", every: 1, .month, effort: .heavy),
        ]
        }
    }
}
