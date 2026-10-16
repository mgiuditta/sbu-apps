import Foundation

nonisolated extension VideoJob {
    /// The file name as VoiceOver should read it: "IMG 1669" instead of "I M G underscore 1669
    /// dot MOV". The extension says nothing the screen does not.
    var spokenName: String {
        let base = (name as NSString).deletingPathExtension
        let words = base.replacing("_", with: " ").replacing("-", with: " ")
            .split(separator: " ", omittingEmptySubsequences: true)
            .joined(separator: " ")
        return words.isEmpty ? name : words
    }
}
