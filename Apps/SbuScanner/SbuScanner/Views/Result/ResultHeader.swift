import SbuKit
import SwiftUI

/// The kind of content, the type of code and when it was read.
struct ResultHeader: View {
    let record: ScanRecord
    let content: CodeContent

    var body: some View {
        SbuListRow(
            "\(Text(content.kind.title))",
            subtitle: "\(record.symbology.name) · \(record.date.formatted(date: .abbreviated, time: .shortened))",
            systemImage: content.kind.systemImage,
            iconBackground: SbuTheme.accentScanner
        )
    }
}

#Preview("Light") {
    List { ResultHeader(record: ScanRecord(raw: "4006381333931", symbology: .ean13), content: .product("4006381333931")) }
}

#Preview("Dark") {
    List { ResultHeader(record: ScanRecord(raw: "ciao", symbology: .qr), content: .text("ciao")) }
        .preferredColorScheme(.dark)
}
