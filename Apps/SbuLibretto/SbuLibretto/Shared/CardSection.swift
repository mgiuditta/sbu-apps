import SbuKit
import SwiftUI

/// A group of the tool screen on paper: its name in inkMuted, when it has one, then its content.
struct CardSection<Content: View>: View {
    let title: Text?
    let content: Content

    init(_ title: LocalizedStringKey, @ViewBuilder content: () -> Content) {
        self.init(title: Text(title), content: content)
    }

    init(title: Text?, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: SbuTheme.space2) {
            if let title {
                title
                    .font(SbuTheme.footnote)
                    .foregroundStyle(SbuTheme.inkMuted)
                    .padding(.horizontal, SbuTheme.space4)
                    .accessibilityAddTraits(.isHeader)
            }
            content
        }
    }
}

#Preview("Light") {
    CardSection("Statistiche") {
        SbuListCard([StatisticValue(id: "arithmetic", title: "Media aritmetica", value: "27,40")]) { value in
            ValueRow(title: value.title, value: value.value)
        }
    }
    .padding(SbuTheme.space4)
    .frame(maxHeight: .infinity, alignment: .top)
    .sbuPaper(grid: false)
}

#Preview("Dark") {
    CardSection(title: nil) {
        SbuListCard([StatisticValue(id: "base", title: "Base di laurea", value: "101,85")]) { value in
            ValueRow(title: value.title, value: value.value)
        }
    }
    .padding(SbuTheme.space4)
    .frame(maxHeight: .infinity, alignment: .top)
    .sbuPaper(grid: false)
    .preferredColorScheme(.dark)
}
