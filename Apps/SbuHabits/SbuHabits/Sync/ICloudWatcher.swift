import Foundation

/// Tells when iCloud changes the copy of the habits, for example after another iPhone synced,
/// with a metadata query on the app's iCloud container. The query only watches: reading the
/// file is `ICloudHabitsFile`'s job, off the main actor.
final class ICloudWatcher {
    /// Called on the main actor after the first look and after every change iCloud reports.
    var onChange: (@MainActor () -> Void)?
    /// The query has looked once: it knows whether a copy exists on iCloud, even one not
    /// downloaded yet.
    private(set) var hasGathered = false

    private var query: NSMetadataQuery?
    private var observers: [any NSObjectProtocol] = []

    func start() {
        guard query == nil else { return }
        let query = NSMetadataQuery()
        // Data, not Documents: the copy is hidden from the Files app.
        query.searchScopes = [NSMetadataQueryUbiquitousDataScope]
        query.predicate = NSPredicate(format: "%K == %@", NSMetadataItemFSNameKey, ICloudHabitsFile.fileName)
        query.operationQueue = .main
        for name in [Notification.Name.NSMetadataQueryDidFinishGathering, .NSMetadataQueryDidUpdate] {
            observers.append(NotificationCenter.default.addObserver(forName: name, object: query, queue: .main) { [weak self] _ in
                MainActor.assumeIsolated {
                    self?.hasGathered = true
                    self?.onChange?()
                }
            })
        }
        self.query = query
        query.start()
    }

    func stop() {
        query?.stop()
        query = nil
        hasGathered = false
        for observer in observers {
            NotificationCenter.default.removeObserver(observer)
        }
        observers = []
    }
}
