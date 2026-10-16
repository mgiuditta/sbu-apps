#if DEBUG
import SbuKit
import SwiftUI

/// Taratura, in Debug builds only: the readings of the nearby devices as heard and smoothed,
/// with their band, and the thresholds as sliders, saved on this iPhone. Not translated and not
/// in Release: it is for tuning `SignalTuning` with real earbuds before its defaults are fixed.
struct TuningView: View {
    let model: ScanModel

    @State private var tuning = SignalTuning.current

    var body: some View {
        Form {
            Section {
                if model.devices.isEmpty && model.myMatches.isEmpty {
                    Text(verbatim: "Nessun dispositivo sentito")
                        .foregroundStyle(SbuTheme.inkMuted)
                }
                ForEach(model.myMatches.values.map(\.device) + model.devices) { device in
                    TuningReadingRow(device: device)
                }
            } header: {
                Text(verbatim: "Letture")
            } footer: {
                Text(verbatim: "Grezzo: l'ultima lettura. Filtrato: la mediana di 5 con lo smorzamento. Si aggiorna due volte al secondo.")
            }

            Section {
                TuningSlider(title: "Più lontano (dBm)", value: $tuning.farthestRSSI, range: -120...(-70), step: 1)
                TuningSlider(title: "Più vicino (dBm)", value: $tuning.nearestRSSI, range: -60...(-20), step: 1)
                TuningSlider(title: "Smorzamento", value: $tuning.smoothing, range: 0.05...1, step: 0.05)
            } header: {
                Text(verbatim: "Scala")
            }

            Section {
                TuningIntSlider(title: "Tiepido da (%)", value: $tuning.warmFrom, range: 5...90)
                TuningIntSlider(title: "Caldo da (%)", value: $tuning.hotFrom, range: 10...95)
                TuningIntSlider(title: "Qui vicino da (%)", value: $tuning.veryCloseFrom, range: 15...100)
                TuningIntSlider(title: "Isteresi (punti)", value: $tuning.hysteresis, range: 0...20)
                TuningIntSlider(title: "Trovato da (%)", value: $tuning.foundAt, range: 50...100)
                TuningIntSlider(title: "Trovato di nuovo sotto (%)", value: $tuning.foundRearmBelow, range: 30...99)
            } header: {
                Text(verbatim: "Parole e trovato")
            }

            Section {
                TuningSlider(title: "Non sentito dopo (s)", value: $tuning.lostAfter, range: 1...15, step: 1)
                TuningSlider(title: "Avviso app aperta (s)", value: $tuning.lostAlertForeground, range: 5...120, step: 5)
                TuningSlider(title: "Avviso in background (s)", value: $tuning.lostAlertBackground, range: 15...600, step: 15)
            } header: {
                Text(verbatim: "Silenzio")
            } footer: {
                Text(verbatim: tuning.isConsistent ? "Valori in uso." : "Valori incoerenti: l'app usa quelli standard finché non li sistemi.")
            }

            Section {
                Button(role: .destructive, action: reset) {
                    Text(verbatim: "Ripristina i valori standard")
                }
            }
        }
        .navigationTitle(Text(verbatim: "Taratura"))
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: tuning, save)
    }

    private func save() {
        tuning.save(to: .standard)
    }

    private func reset() {
        tuning = .standard
    }
}

#Preview("Light") {
    NavigationStack {
        TuningView(model: ScanModel(scanner: FixedScanner()))
    }
}

#Preview("Dark") {
    NavigationStack {
        TuningView(model: ScanModel(scanner: FixedScanner()))
    }
    .preferredColorScheme(.dark)
}
#endif
