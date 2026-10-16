/// Allows notifications without asking and shows none: for the simulator's fixed scanner, UI
/// tests and previews, where a permission alert would cover the screen.
struct AcceptingLostNotifier: LostNotifier {
    func requestPermission() async -> Bool {
        true
    }

    func notifyLost(deviceName: String) {}
}
