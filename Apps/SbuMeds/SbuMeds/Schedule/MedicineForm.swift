import Foundation

/// The shape a medicine comes in: its SF Symbol and the unit a dose is counted in.
/// No pill pictures or colors, only the system's symbols.
nonisolated enum MedicineForm: String, CaseIterable, Codable, Sendable, Identifiable {
    case tablet
    case capsule
    case liquid
    case drops
    case injection
    case inhaler
    case spray
    case patch
    case cream
    case other

    var id: String { rawValue }

    var systemImage: String {
        switch self {
        case .tablet: "pills"
        case .capsule: "pill"
        case .liquid: "waterbottle"
        case .drops: "drop"
        case .injection: "syringe"
        case .inhaler: "lungs"
        case .spray: "nose"
        case .patch: "bandage"
        case .cream: "hand.raised"
        case .other: "cross.case"
        }
    }

    var name: LocalizedStringResource {
        switch self {
        case .tablet: "Compressa"
        case .capsule: "Capsula"
        case .liquid: "Sciroppo"
        case .drops: "Gocce"
        case .injection: "Iniezione"
        case .inhaler: "Inalatore"
        case .spray: "Spray"
        case .patch: "Cerotto"
        case .cream: "Crema"
        case .other: "Altro"
        }
    }

    /// The step of the amount stepper: half tablets, 2.5 ml of syrup, one drop.
    var step: Double {
        switch self {
        case .tablet: 0.5
        case .liquid: 2.5
        default: 1
        }
    }

    /// The unit for `amount`, singular for exactly one: "1 compressa", "2 compresse", "0,5 compresse".
    func unit(for amount: Double, locale: Locale = .current) -> String {
        let one = amount == 1
        return switch self {
        case .tablet: one ? String(localized: "compressa", locale: locale) : String(localized: "compresse", locale: locale)
        case .capsule: one ? String(localized: "capsula", locale: locale) : String(localized: "capsule", locale: locale)
        case .liquid: String(localized: "ml", locale: locale)
        case .drops: one ? String(localized: "goccia", locale: locale) : String(localized: "gocce", locale: locale)
        case .injection: one ? String(localized: "iniezione", locale: locale) : String(localized: "iniezioni", locale: locale)
        case .inhaler, .spray: one ? String(localized: "spruzzo", locale: locale) : String(localized: "spruzzi", locale: locale)
        case .patch: one ? String(localized: "cerotto", locale: locale) : String(localized: "cerotti", locale: locale)
        case .cream: one ? String(localized: "applicazione", locale: locale) : String(localized: "applicazioni", locale: locale)
        case .other: one ? String(localized: "dose", locale: locale) : String(localized: "dosi", locale: locale)
        }
    }

    /// "1 compressa", "2,5 ml".
    func amountText(_ amount: Double, locale: Locale = .current) -> String {
        "\(amount.formatted(.number.precision(.fractionLength(0...2)).locale(locale))) \(unit(for: amount, locale: locale))"
    }
}
