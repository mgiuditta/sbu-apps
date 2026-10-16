import Foundation

extension GraduationBase {
    /// The base out of 110, and what the exams alone reach when it is more: "110 (dagli esami 113,78)".
    var text: String {
        let shown = LibrettoFormat.base(value)
        guard isAboveMaximum else { return shown }
        return String(localized: "\(shown) (dagli esami \(unrounded.formatted(LibrettoFormat.average)))")
    }
}
