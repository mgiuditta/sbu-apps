import SwiftUI

/// A list on paper: rows on `surfaceRaised`, separated by `line` hairlines, inside a 1 px `line`
/// border with `radiusCard`. For lists on the tool screen's paper; management screens keep a native
/// `List`.
public struct SbuListCard<Data: RandomAccessCollection, Row: View>: View where Data.Element: Identifiable {
    private let data: Data
    private let row: (Data.Element) -> Row

    /// Creates the card.
    /// - Parameters:
    ///   - data: The rows' items.
    ///   - row: One row; the card adds padding, separators and the border.
    public init(_ data: Data, @ViewBuilder row: @escaping (Data.Element) -> Row) {
        self.data = data
        self.row = row
    }

    public var body: some View {
        let shape = RoundedRectangle(cornerRadius: SbuTheme.radiusCard)
        VStack(spacing: 0) {
            ForEach(data) { item in
                if item.id != data.first?.id {
                    Rectangle()
                        .fill(SbuTheme.line)
                        .frame(height: SbuTheme.hairline)
                }
                row(item)
                    .font(SbuTheme.body)
                    .foregroundStyle(SbuTheme.ink)
                    .padding(.horizontal, SbuTheme.space4)
                    .padding(.vertical, SbuTheme.space3)
                    .frame(maxWidth: .infinity, minHeight: SbuTheme.controlRoundSm, alignment: .leading)
            }
        }
        .background(SbuTheme.surfaceRaised, in: shape)
        .clipShape(shape)
        .overlay {
            shape.strokeBorder(SbuTheme.line, lineWidth: SbuTheme.hairline)
        }
    }
}

#Preview("Light") {
    SbuListCardPreview()
}

#Preview("Dark") {
    SbuListCardPreview()
        .preferredColorScheme(.dark)
}

#Preview("AX5") {
    SbuListCardPreview()
        .dynamicTypeSize(.accessibility5)
}

private struct SbuListCardPreview: View {
    private struct Renewal: Identifiable {
        let id: String
        let soon: Bool
    }

    var body: some View {
        SbuListCard([Renewal(id: "iCloud+", soon: true), Renewal(id: "Palestra", soon: false)]) { renewal in
            HStack(spacing: SbuTheme.space3) {
                SbuRowMark(filled: renewal.soon)
                Text(verbatim: renewal.id)
            }
        }
        .padding(SbuTheme.space4)
        .frame(maxHeight: .infinity, alignment: .top)
        .sbuPaper()
    }
}
