import SbuKit
import SwiftUI

/// Tody's three buttons: done now, done on a day you pick, pause or resume.
struct ChoreActionsSection: View {
    let isPaused: Bool
    let isOneOff: Bool
    let markDoneNow: () -> Void
    let pickDay: () -> Void
    let togglePause: () -> Void

    var body: some View {
        Section {
            Button("Fatta ora", systemImage: "checkmark.circle", action: markDoneNow)
                .accessibilityIdentifier("doneNow")
            Button("Fatta il…", systemImage: "calendar", action: pickDay)
                .accessibilityIdentifier("doneOn")
            Button(isPaused ? "Riprendi" : "Metti in pausa", systemImage: isPaused ? "play.circle" : "pause.circle", action: togglePause)
                .accessibilityIdentifier("pause")
        } footer: {
            if isOneOff {
                Text("Una tantum: quando la segni come fatta, sparisce.")
            } else if isPaused {
                Text("In pausa non diventa mai da fare. Riprendi quando torni.")
            }
        }
        .listRowBackground(SbuTheme.surfaceRaised)
    }
}

#Preview("Light") {
    ChoreActionsSectionPreview()
}

#Preview("Dark") {
    ChoreActionsSectionPreview()
        .preferredColorScheme(.dark)
}

private struct ChoreActionsSectionPreview: View {
    var body: some View {
        List {
            ChoreActionsSection(isPaused: false, isOneOff: false, markDoneNow: {}, pickDay: {}, togglePause: {})
            ChoreActionsSection(isPaused: true, isOneOff: true, markDoneNow: {}, pickDay: {}, togglePause: {})
        }
        .scrollContentBackground(.hidden)
        .background(SbuTheme.paper)
        .environment(\.sbuAccent, .tidy)
    }
}
