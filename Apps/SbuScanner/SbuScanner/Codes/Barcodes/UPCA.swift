/// UPC-A, the American product number: 11 digits and a check digit. It is an EAN-13 that starts with 0.
nonisolated enum UPCA {
    static func normalized(_ text: String) -> String? {
        GTIN.normalized(text, length: 12)
    }

    static func modules(_ code: String) -> [Bool] {
        EAN13.modules("0" + code)
    }
}
