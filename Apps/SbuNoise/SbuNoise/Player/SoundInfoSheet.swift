import SbuKit
import SwiftUI

/// The ⓘ of the player: what the sound is and where it comes from.
struct SoundInfoSheet: View {
    @Environment(\.dismiss) private var dismiss
    let sound: Sound

    var body: some View {
        NavigationStack {
            List {
                Section("Fonte") {
                    Text("Generato in tempo reale")
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle(Text(sound.name))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Fine") { dismiss() }
                }
            }
        }
    }
}

#Preview("Light") {
    Color.clear.sheet(isPresented: .constant(true)) { SoundInfoSheet(sound: Sound.generated[0]) }
}

#Preview("Dark") {
    Color.clear.sheet(isPresented: .constant(true)) { SoundInfoSheet(sound: Sound.generated[0]) }
        .preferredColorScheme(.dark)
}
