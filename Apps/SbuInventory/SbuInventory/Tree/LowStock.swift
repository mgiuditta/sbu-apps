/// The "Da ricomprare" rule: an item with a minimum is low once its quantity is at or below it.
nonisolated enum LowStock {
    static func isLow(quantity: Int, minimum: Int?) -> Bool {
        guard let minimum else { return false }
        return quantity <= minimum
    }
}
