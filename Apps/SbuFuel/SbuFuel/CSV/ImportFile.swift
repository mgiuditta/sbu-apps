import Foundation

/// A CSV file picked for import, read and waiting for its columns to be mapped.
struct ImportFile: Identifiable {
    let id = UUID()
    let importer: CSVImporter
    let name: String
}
