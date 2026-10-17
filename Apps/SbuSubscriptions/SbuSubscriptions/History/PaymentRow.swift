import SbuKit
import SwiftUI

/// One payment made: its day and amount, and "Pagato" with a filled mark once you mark it paid.
struct PaymentRow: View {
    let day: Date
    let amount: Decimal
    let currencyCode: String
    let isPaid: Bool
    let markPaid: () -> Void

    var body: some View {
        LabeledContent {
            if isPaid {
                HStack(spacing: SbuTheme.space2) {
                    SbuRowMark(filled: true)
                    Text("Pagato")
                        .foregroundStyle(SbuTheme.ink)
                }
            } else {
                Button("Segna come pagato", action: markPaid)
                    .buttonStyle(.borderless)
            }
        } label: {
            VStack(alignment: .leading) {
                Text(day, format: .dateTime.day().month(.wide).year())
                Text(amount, format: .currency(code: currencyCode))
                    .font(SbuTheme.subheadline)
                    .monospacedDigit()
                    .foregroundStyle(SbuTheme.inkMuted)
            }
        }
    }
}

#Preview("Light") {
    List {
        PaymentRow(day: .now, amount: 9.99, currencyCode: "EUR", isPaid: true) {}
        PaymentRow(day: .now, amount: 9.99, currencyCode: "EUR", isPaid: false) {}
    }
}

#Preview("Dark") {
    List {
        PaymentRow(day: .now, amount: 9.99, currencyCode: "EUR", isPaid: true) {}
        PaymentRow(day: .now, amount: 9.99, currencyCode: "EUR", isPaid: false) {}
    }
    .preferredColorScheme(.dark)
}
