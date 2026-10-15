import Foundation
import Observation

/// The saved trips, newest first, kept in step with their file.
@Observable
final class TripLog {
    private(set) var trips: [TripRecord]
    /// The file was written by a newer Sbu Speed: it is shown as empty and never overwritten.
    private(set) var isReadOnly = false

    @ObservationIgnored private let store: TripLogStore?

    /// - Parameter store: Where the trips live; `nil` keeps them in memory, for previews.
    init(store: TripLogStore? = .shared) {
        self.store = store
        do {
            trips = try store?.load().trips ?? []
        } catch {
            trips = []
            isReadOnly = error as? TripLogStore.Failure != nil
        }
    }

    /// A log with fixed trips in memory, for previews.
    init(trips: [TripRecord]) {
        store = nil
        self.trips = trips
    }

    func add(_ record: TripRecord) {
        guard !isReadOnly else { return }
        trips.insert(record, at: 0)
        save()
    }

    func delete(_ record: TripRecord) {
        guard !isReadOnly else { return }
        trips.removeAll { $0.id == record.id }
        save()
    }

    private func save() {
        do {
            try store?.save(TripLogFile(trips: trips))
        } catch TripLogStore.Failure.unknownVersion {
            isReadOnly = true
        } catch {
            // A full disk: the trips stay on screen and the next change tries again.
        }
    }
}
