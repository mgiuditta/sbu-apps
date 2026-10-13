import SbuKit
import SwiftUI

/// The current step of the calibration: what to do, the Misura button or the capture progress, and the result.
struct CalibrationStepSection: View {
    let session: CalibrationSession
    /// The side being calibrated.
    let side: CalibrationTarget
    let measure: () -> Void
    let calibrateAnother: () -> Void

    private var instruction: LocalizedStringKey {
        switch session.step {
        case .first: "Appoggia l'iPhone sul lato da calibrare, un bordo o il retro, e tocca Misura. Non serve una superficie in bolla."
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
            LabeledContent("Lato") {
                Text(side.name)
                    .foregroundStyle(SbuTheme.inkMuted)
            }

            // The outcome first, where a half-height sheet always shows it.
            if session.step == .done {
                Label("Calibrata", systemImage: "checkmark.circle")
                    .foregroundStyle(SbuTheme.success)
            } else if let notice = session.notice {
                CalibrationNoticeRow(notice: notice)
            }

            Text(instruction)
                .foregroundStyle(SbuTheme.ink)

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
                Button("Calibra un altro lato", action: calibrateAnother)
            }
        } header: {
            Text(title)
        }
    }
}

#Preview("Light") {
    Form {
        CalibrationStepSection(session: CalibrationSession(), side: .edge(.bottom), measure: {}, calibrateAnother: {})
    }
}

#Preview("Dark") {
    Form {
        CalibrationStepSection(session: CalibrationSession(), side: .edge(.bottom), measure: {}, calibrateAnother: {})
    }
    .preferredColorScheme(.dark)
}
