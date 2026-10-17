import SbuKit
import SwiftUI

/// The trip and the latest fix under the figure, one value per row, on the paper of the tool screen.
struct ReadingsCard: View {
    let readings: [SpeedReading]

    var body: some View {
        SbuListCard(readings) { reading in
            ReadingRow(reading: reading)
        }
    }
}

#Preview("Light") {
    ReadingsCard(readings: ReadingRow.previewReadings)
        .padding(SbuTheme.space4)
        .frame(maxHeight: .infinity, alignment: .top)
        .sbuPaper()
}

#Preview("Dark") {
    ReadingsCard(readings: ReadingRow.previewReadings)
        .padding(SbuTheme.space4)
        .frame(maxHeight: .infinity, alignment: .top)
        .sbuPaper()
        .preferredColorScheme(.dark)
}
