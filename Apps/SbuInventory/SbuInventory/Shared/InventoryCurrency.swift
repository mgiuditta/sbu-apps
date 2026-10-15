import Foundation

/// The currency prices are entered and shown in: the one of the iPhone's region.
nonisolated enum InventoryCurrency {
    static var code: String {
        Locale.current.currency?.identifier ?? "EUR"
    }

    static var format: Decimal.FormatStyle.Currency {
        .currency(code: code)
    }
}
