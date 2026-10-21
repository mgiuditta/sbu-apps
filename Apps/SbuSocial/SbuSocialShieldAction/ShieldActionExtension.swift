import ManagedSettings

/// What the Shield's buttons do. For now they only close the app; "Apri in Sbu Social" comes with the Blocco tab.
final class ShieldActionExtension: ShieldActionDelegate {
    override func handle(action: ShieldAction, for application: ApplicationToken, completionHandler: @escaping (ShieldActionResponse) -> Void) {
        completionHandler(.close)
    }
}
