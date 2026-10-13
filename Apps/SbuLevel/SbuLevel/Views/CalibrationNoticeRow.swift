import SbuKit
import SwiftUI

/// Why a calibration capture started over, in `warning` with its word and symbol.
struct CalibrationNoticeRow: View {
    let notice: CalibrationSession.Notice

    private var message: LocalizedStringKey {
        switch notice {
        case .moved: "L'iPhone si è mosso: la misura ricomincia."
        case .wrongSide: "Appoggia l'iPhone sullo stesso lato della prima misura."
        }
    }

    var body: some View {
        Label(message, systemImage: "exclamationmark.triangle")
            .foregroundStyle(SbuTheme.warning)
    }
}

#Preview("Light") {
    List {
        CalibrationNoticeRow(notice: .moved)
        CalibrationNoticeRow(notice: .wrongSide)
    }
}

#Preview("Dark") {
    List {
        CalibrationNoticeRow(notice: .moved)
        CalibrationNoticeRow(notice: .wrongSide)
    }
    .preferredColorScheme(.dark)
}
