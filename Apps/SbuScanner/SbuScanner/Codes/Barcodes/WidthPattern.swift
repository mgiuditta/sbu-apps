/// Bars and spaces written as narrow and wide elements, `n` and `w`, starting with a bar.
nonisolated enum WidthPattern {
    /// - Parameter wide: Modules in a wide element; narrow is one.
    static func modules(_ pattern: String, wide: Int = 3) -> [Bool] {
        pattern.enumerated().flatMap { index, element in
            Array(repeating: index.isMultiple(of: 2), count: element == "w" ? wide : 1)
        }
    }
}
