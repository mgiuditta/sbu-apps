import SbuKit
import SwiftUI

/// A code in the history: what it says, its kind and when.
struct HistoryRow: View {
    let record: ScanRecord

    var body: some View {
        let content = record.content
        SbuListRow(
            "\(content.summary)",
            subtitle: subtitle(content),
            systemImage: content.kind.systemImage,
            iconBackground: SbuTheme.surfaceSunken,
            iconForeground: SbuTheme.inkMuted
        )
    }

    private func subtitle(_ content: CodeContent) -> LocalizedStringKey {
        let date = record.date.formatted(date: .abbreviated, time: .shortened)
        if let folder = record.folder {
            return "\(Text(content.kind.title)) · \(folder.name) · \(date)"
        }
        return "\(Text(content.kind.title)) · \(date)"
    }
}

#Preview("Light") {
    List { HistoryRow(record: ScanRecord(raw: "https://sbu.dev", symbology: .qr)) }
}

#Preview("Dark") {
    List { HistoryRow(record: ScanRecord(raw: "4006381333931", symbology: .ean13)) }
        .preferredColorScheme(.dark)
}
