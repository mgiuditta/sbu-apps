import SbuKit
import SwiftUI

/// The one figure of the inventory and of each folder: how many things, closed by the full stop.
/// Under it, how many different items in how many folders and, when prices exist, what they are worth.
struct TotalFigure: View {
    let total: InventoryTotal

    var body: some View {
        SbuStat("Oggetti", value: total.quantity, format: .number, context: context)
            .accessibilityIdentifier("total")
    }

    private var context: LocalizedStringKey {
        let value = total.value?.formatted(InventoryCurrency.format)
        switch (total.folderCount > 0, value) {
        case let (true, value?):
            return "^[\(total.itemCount) voce](inflect: true) in ^[\(total.folderCount) cartella](inflect: true) · \(value)"
        case (true, nil):
            return "^[\(total.itemCount) voce](inflect: true) in ^[\(total.folderCount) cartella](inflect: true)"
        case let (false, value?):
            return "^[\(total.itemCount) voce](inflect: true) · \(value)"
        case (false, nil):
            return "^[\(total.itemCount) voce](inflect: true)"
        }
    }
}

#Preview("Light") {
    TotalFigure(total: InventoryTotal(quantity: 42, itemCount: 7, folderCount: 4, value: Decimal(string: "712.10")))
        .padding(SbuTheme.space4)
        .tint(SbuTheme.accentInventory)
}

#Preview("Dark") {
    TotalFigure(total: InventoryTotal(quantity: 1, itemCount: 1))
        .padding(SbuTheme.space4)
        .tint(SbuTheme.accentInventory)
        .preferredColorScheme(.dark)
}
