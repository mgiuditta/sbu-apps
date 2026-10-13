import SbuKit
import SwiftUI

/// Where the duplicate scan is: progress with a way to stop it, or a way to start it again.
struct ScanStatusView: View {
    let model: CleanModel

    var body: some View {
        switch model.scan {
        case .running(let done, let total):
            VStack(alignment: .leading, spacing: SbuTheme.space2) {
                ProgressView(value: Double(done), total: Double(max(total, 1))) {
                    Text("Analizzo le foto: \(done) di \(total)")
                        .font(SbuTheme.subheadline)
                        .foregroundStyle(SbuTheme.ink)
                }
                Text("Tutto succede su questo iPhone. Puoi usare il resto dell'app intanto.")
                    .font(SbuTheme.footnote)
                    .foregroundStyle(SbuTheme.inkMuted)
                Button("Interrompi", action: model.cancelScan)
                    .buttonStyle(SbuFieldPillStyle())
            }
        case .cancelled:
            VStack(alignment: .leading, spacing: SbuTheme.space2) {
                Text("Analisi interrotta. Le foto già analizzate restano: riprendi da dove eri.")
                    .font(SbuTheme.subheadline)
                    .foregroundStyle(SbuTheme.inkMuted)
                Button("Riprendi l'analisi", action: model.startScan)
                    .buttonStyle(SbuFieldPillStyle())
            }
        case .idle, .finished:
            EmptyView()
        }
    }
}

#Preview("Light") {
    ScanStatusView(model: .preview)
        .padding()
}

#Preview("Dark") {
    ScanStatusView(model: .preview)
        .padding()
        .preferredColorScheme(.dark)
}
