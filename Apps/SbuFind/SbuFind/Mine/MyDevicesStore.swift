import Foundation

/// Keeps your saved devices in a local file, excluded from backup.
struct MyDevicesStore {
    /// The file in Application Support.
    static var defaultURL: URL {
        URL.applicationSupportDirectory.appending(path: "my-devices.json")
    }

    let url: URL

    init(url: URL = MyDevicesStore.defaultURL) {
        self.url = url
    }

    /// The saved devices; `nil` when the file is there but cannot be read now.
    func read() -> [SavedDevice]? {
        switch LocalFile<[SavedDevice]>(url: url).read() {
        case .empty: []
        case .loaded(let devices): devices
        case .unavailable: nil
        }
    }

    /// The saved devices; empty when there are none or they cannot be read now.
    func load() -> [SavedDevice] {
        read() ?? []
    }

    func save(_ devices: [SavedDevice]) {
        LocalFile(url: url).save(devices)
    }
}
