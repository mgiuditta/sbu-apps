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

    func load() -> [SavedDevice] {
        LocalFile<[SavedDevice]>(url: url).load() ?? []
    }

    func save(_ devices: [SavedDevice]) {
        LocalFile(url: url).save(devices)
    }
}
