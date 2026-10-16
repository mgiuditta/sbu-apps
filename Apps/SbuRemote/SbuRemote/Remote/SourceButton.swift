import SbuKit
import SwiftUI

/// Source: the list of inputs where the TV gives one (LG, Sony), the Source key elsewhere.
struct SourceButton: View {
    let session: RemoteSession

    @State private var inputs: [TVShortcut] = []
    @State private var isPicking = false
    @State private var presses = 0

    var body: some View {
        Button(action: open) {
            Image(systemName: RemoteKey.source.systemImage)
                .fontWeight(.medium)
                .imageScale(.medium)
                .font(SbuTheme.headline)
                .frame(minWidth: SbuTheme.controlRoundSm, minHeight: SbuTheme.controlRoundSm)
        }
        .buttonStyle(.bordered)
        .buttonBorderShape(.roundedRectangle(radius: SbuTheme.radiusLg))
        .disabled(!session.status.acceptsKeys)
        .accessibilityLabel(Text(RemoteKey.source.title))
        .sensoryFeedback(.impact(weight: .light), trigger: presses)
        .sheet(isPresented: $isPicking) {
            ShortcutListSheet(title: "Sorgente", systemImage: "rectangle.on.rectangle", items: inputs) { input in
                Task { await session.run { try await $0.switchInput(input) } }
            }
        }
    }

    private func open() {
        presses += 1
        Task {
            var listed: [TVShortcut] = []
            await session.run { listed = try await $0.inputs() }
            if listed.isEmpty {
                await session.press(.source)
            } else {
                inputs = listed
                isPicking = true
            }
        }
    }
}
