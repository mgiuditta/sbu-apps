import SbuKit
import SwiftUI

/// Columns, rows and what goes in the cells.
///
/// DrawinGrid locks the rows without a word when the cells are square, and its reviews complain
/// that the rows cannot be changed: here the rows still show how many they are, and the footer
/// says why they follow the columns.
struct CellsSection: View {
    @Binding var settings: GridSettings
    /// The grid as drawn now, for the rows square cells or a sheet decide.
    let count: GridCount
    let cellRule: CellRule

    private var rowsFollowColumns: Bool {
        if case .divide = cellRule { false } else { true }
    }

    private var columnsFollowPaper: Bool {
        if case .physical = cellRule { true } else { false }
    }

    var body: some View {
        Section {
            CountStepper(title: "Colonne", value: $settings.columns, range: GridSettings.columnRange, shown: count.columns)
                .disabled(columnsFollowPaper)
                .sbuAffectsFigure(settings.columns)

            CountStepper(title: "Righe", value: $settings.rows, range: GridSettings.rowRange, shown: count.rows)
                .disabled(rowsFollowColumns)
                .sbuAffectsFigure(settings.rows)

            Toggle("Celle quadrate", isOn: $settings.hasSquareCells)
                .disabled(columnsFollowPaper)
                .sbuAffectsFigure(settings.hasSquareCells)

            Toggle("Diagonali", isOn: $settings.showsDiagonals)

            Toggle("Numeri di righe e colonne", isOn: $settings.showsNumbers)
        } header: {
            Text("Celle")
        } footer: {
            if columnsFollowPaper {
                Text("Righe e colonne vengono dal foglio e dalla misura della cella. Le cambi in Foglio.")
            } else if rowsFollowColumns {
                Text("Con le celle quadrate le righe seguono le colonne e la forma della foto.")
            }
        }
    }
}

#Preview("Light") {
    @Previewable @State var settings = GridSettings()
    Form {
        CellsSection(settings: $settings, count: GridCount(columns: 4, rows: 6), cellRule: settings.cellRule)
    }
}

#Preview("Dark") {
    @Previewable @State var settings = GridSettings()
    Form {
        CellsSection(settings: $settings, count: GridCount(columns: 4, rows: 6), cellRule: settings.cellRule)
    }
    .preferredColorScheme(.dark)
}
