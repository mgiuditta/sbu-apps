import SbuKit
import SwiftUI

/// Speak, then send: the words go to the TV's text field, as from the keyboard, and are confirmed.
struct VoiceSheet: View {
    let session: RemoteSession
    let voice: VoiceSearch

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                Section {
                    HStack(spacing: SbuTheme.space3) {
                        Image(systemName: voice.phase == .listening ? "waveform" : "mic")
                            .fontWeight(.medium)
                            .foregroundStyle(SbuTheme.inkMuted)
                            .symbolEffect(.variableColor.iterative, isActive: voice.phase == .listening)
                            .accessibilityHidden(true)
                        Text(voice.transcript.isEmpty ? String(localized: "Parla adesso") : voice.transcript)
                            .font(SbuTheme.body)
                            .foregroundStyle(voice.transcript.isEmpty ? SbuTheme.inkMuted : SbuTheme.ink)
                    }
                } footer: {
                    Text(footer)
                }
                .listRowBackground(SbuTheme.surfaceRaised)
            }
            .listStyle(.insetGrouped)
            .scrollContentBackground(.hidden)
            .background(SbuTheme.paper)
            .navigationTitle("Cerca con la voce")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annulla", action: cancel)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Invia", action: send)
                        .disabled(voice.transcript.isEmpty)
                }
            }
            .task {
                await voice.start()
            }
            .onDisappear {
                voice.stop()
            }
        }
        .presentationDetents([.medium])
    }

    private var footer: LocalizedStringResource {
        switch voice.phase {
        case .denied: "Sbu Remote non ha il permesso del microfono o del riconoscimento vocale. Puoi darlo in Impostazioni."
        case .failed: "Non ho capito. Chiudi e riprova."
        case .idle, .listening: "Il riconoscimento avviene sull'iPhone: l'audio non esce dal telefono."
        }
    }

    private func send() {
        let text = voice.stop()
        Task {
            await session.run { try await $0.sendText(text) }
            await session.run { try await $0.submitText() }
        }
        dismiss()
    }

    private func cancel() {
        voice.stop()
        dismiss()
    }
}

#Preview("Light") {
    Color.clear
        .sheet(isPresented: .constant(true)) {
            VoiceSheet(session: .preview, voice: VoiceSearch())
        }
        .tint(SbuTheme.ink)
}

#Preview("Dark") {
    Color.clear
        .sheet(isPresented: .constant(true)) {
            VoiceSheet(session: .preview, voice: VoiceSearch())
        }
        .tint(SbuTheme.ink)
        .preferredColorScheme(.dark)
}
