import AppIntents
import Foundation

/// The reply every key intent gives: done on which TV, or why not.
/// Key intents run in the app's process, which holds the TV's credential and the Local Network permission.
enum RemoteKeyIntent {
    static func press(_ key: RemoteKey) async -> IntentDialog {
        do {
            let name = try await RemoteCommand.send(key)
            return "Fatto su \(name)."
        } catch RemoteCommand.Failure.noTV {
            return "Aggiungi prima una TV in Sbu Remote."
        } catch {
            return "La TV non risponde. Controlla che sia accesa e sulla stessa Wi-Fi."
        }
    }
}
