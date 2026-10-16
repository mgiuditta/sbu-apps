import SbuKit
import SwiftUI

/// Typing into the TV: the text goes to the TV's active field as you write, Invio confirms it.
struct KeyboardSheet: View {
    let session: RemoteSession

    @Environment(\.dismiss) private var dismiss
    @State private var text = ""
    @FocusState private var isFocused: Bool

    var body: some View {
        NavigationStack {
            List {
                Section {
                    TextField("Scrivi sulla TV", text: $text)
                        .focused($isFocused)
                        .submitLabel(.search)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .onSubmit(submit)
                } footer: {
                    Text("Apri prima una casella di testo sulla TV, per esempio la ricerca di un'app.")
                }
                .listRowBackground(SbuTheme.surfaceRaised)
            }
            .listStyle(.insetGrouped)
            .scrollContentBackground(.hidden)
            .background(SbuTheme.surface)
            .navigationTitle("Tastiera")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Fine", action: close)
                }
            }
            .onAppear { isFocused = true }
            .onChange(of: text) { _, newValue in
                send(newValue)
            }
        }
        .presentationDetents([.medium])
    }

    private func send(_ value: String) {
        Task { await session.run { try await $0.sendText(value) } }
    }

    private func submit() {
        Task {
            await session.run { try await $0.submitText() }
            text = ""
        }
    }

    private func close() {
        dismiss()
    }
}

#Preview("Light") {
    Color.clear
        .sheet(isPresented: .constant(true)) {
            KeyboardSheet(session: .preview)
        }
        .tint(SbuTheme.accentRemote)
}

#Preview("Dark") {
    Color.clear
        .sheet(isPresented: .constant(true)) {
            KeyboardSheet(session: .preview)
        }
        .tint(SbuTheme.accentRemote)
        .preferredColorScheme(.dark)
}
