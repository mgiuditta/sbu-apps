import Foundation

/// A file picked for import, read: the lines of its CSV and, from an archive, the photos they name.
nonisolated struct ImportFile: Sendable {
    enum Failure: Error, Equatable {
        /// Empty, not text, or a damaged archive.
        case unreadable
        /// An archive without a CSV inside.
        case noCSV
        /// A CSV without a column for the names.
        case noNameColumn
        /// An archive with more files or bytes than an inventory can hold, or one built to expand without end.
        case tooLarge
    }

    let rows: [InventoryRow]
    let photos: [String: Data]

    /// Items in the file, folders left out.
    var itemCount: Int { rows.count { $0.kind == .item } }

    init(rows: [InventoryRow], photos: [String: Data]) {
        self.rows = rows
        self.photos = photos
    }

    /// Reads a CSV, or a ZIP with a CSV and photos.
    init(data: Data, calendar: Calendar) throws(Failure) {
        var text: String
        var photos: [String: Data] = [:]
        if data.starts(with: [0x50, 0x4B, 0x03, 0x04]) {
            let files: [String: Data]
            do {
                files = try ZipReader.files(in: data)
            } catch .tooLarge {
                throw .tooLarge
            } catch {
                throw .unreadable
            }
            // Ours is inventory.csv; any CSV will do for an archive zipped by hand, the shortest path first.
            let csvNames = files.keys.filter { $0.lowercased().hasSuffix(".csv") && !$0.hasPrefix("__MACOSX") }
            guard let name = csvNames.first(where: { $0.hasSuffix(InventoryExport.csvName) }) ?? csvNames.min(by: { $0.count < $1.count }),
                  let csv = files[name] else { throw .noCSV }
            text = String(decoding: csv, as: UTF8.self)
            // Paths in the CSV are relative to it, wherever it sits in the archive.
            let base = name.contains("/") ? String(name[...name.lastIndex(of: "/")!]) : ""
            for (path, file) in files where path != name && path.hasPrefix(base) {
                photos[String(path.dropFirst(base.count))] = file
            }
        } else {
            text = String(decoding: data, as: UTF8.self)
        }
        if text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty { throw .unreadable }
        do {
            rows = try InventoryCSV.rows(text, calendar: calendar)
        } catch .empty {
            throw .unreadable
        } catch {
            throw .noNameColumn
        }
        self.photos = photos
    }
}
