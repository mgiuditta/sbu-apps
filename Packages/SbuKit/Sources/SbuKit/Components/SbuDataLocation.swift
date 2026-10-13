/// Where an app keeps the user's data, as the promise pills say it.
///
/// Every app keeps data on the iPhone. An app that syncs through the user's own iCloud (ADR-0008)
/// passes `.yourDevices` while sync is on, so the promise stays true.
nonisolated public enum SbuDataLocation: Sendable {
    /// Only on this iPhone: the default for every app.
    case thisDevice
    /// Only on the user's devices, through their own iCloud.
    case yourDevices
}
