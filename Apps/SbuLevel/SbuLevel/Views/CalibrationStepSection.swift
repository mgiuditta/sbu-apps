import SbuKit
import SwiftUI

/// The current step of the calibration: what to do, the Misura button or the capture progress, and the result.
struct CalibrationStepSection: View {
    let session: CalibrationSession
    let measure: () -> Void
    let calibrateAnother: () -> Void

    private var instruction: LocalizedStringKey {
        switch session.step {
        case .first: "Appoggia l'iPhone sul lato da calibrare e tocca Misura. Non serve una superficie in bolla."
        case .second: "Gira l'iPhone di 180° sullo stesso punto, sullo stesso lato, e tocca Misura."
        case .done: "Le due misure si compensano: l'errore del sensore è corretto anche se la superficie non è in bolla."
        }
    }

    private var title: LocalizedStringKey {
        switch session.step {
        case .first: "Passo 1 di 2"
        case .second: "Passo 2 di 2"
        case .done: "Risultato"
        }
    }

    var body: some View {
        Section {
            Text(instruction)
                .foregroundStyle(SbuTheme.ink)

            if let notice = session.notice {
                CalibrationNoticeRow(notice: notice)
            }

            switch session.step {
            case .first, .second:
                if session.isCapturing {
                    ProgressView(value: session.progress) {
                        Text("Misura in corso: tieni fermo l'iPhone")
                            .foregroundStyle(SbuTheme.inkMuted)
                    }
                } else {
                    Button("Misura", action: measure)
                }
            case .done:
                Label("Calibrata", systemImage: "checkmark.circle")
                    .foregroundStyle(SbuTheme.success)
                Button("Calibra un altro lato", action: calibrateAnother)
            }
        } header: {
            Text(title)
        }
    }
}

#Preview("Light") {
    Form {
        CalibrationStepSection(session: CalibrationSession(), measure: {}, calibrateAnother: {})
    }
}

#Preview("Dark") {
    Form {
        CalibrationStepSection(session: CalibrationSession(), measure: {}, calibrateAnother: {})
    }
    .preferredColorScheme(.dark)
}
