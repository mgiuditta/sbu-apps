import Foundation

extension MediaItem {
    /// What VoiceOver says about the item: kind, date and size.
    var spokenDescription: String {
        let date = creationDate?.formatted(date: .long, time: .omitted) ?? String(localized: "senza data")
        let size = bytes.sizeText
        if isScreenRecording {
            return String(localized: "Registrazione dello schermo, \(date), \(size)")
        }
        if kind == .video {
            return String(localized: "Video, \(date), \(size)")
        }
        if isScreenshot {
            return String(localized: "Screenshot, \(date), \(size)")
        }
        return String(localized: "Foto, \(date), \(size)")
    }

    /// The length of a video, such as "1:23".
    var durationText: String {
        Duration.seconds(duration.rounded()).formatted(.time(pattern: duration >= 3600 ? .hourMinuteSecond : .minuteSecond))
    }
}
