import Foundation

/// Reads one messaging app's export format.
///
/// WhatsApp is the only one in 1.0; Telegram's export would be another conforming type, picked by
/// `ChatImporter` from the file it receives.
nonisolated protocol ChatExportParser {
    /// Reads every message of `source` and hands each one to `emit`, in file order.
    /// - Parameter progress: The fraction of the work done, from 0 to 1.
    /// - Returns: The format read, stored with the chat, such as `ios` or `android`.
    func parse(_ source: ChatTextSource, progress: (Double) -> Void, emit: (ParsedMessage) throws -> Void) throws -> String
}
