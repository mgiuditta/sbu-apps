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
                    LabeledContent("Gruppo") {
                        Text(sound.category.title)
                    }
                    switch sound.source {
                    case .generated:
                        Text("Generato in tempo reale")
                    case .loop(_, credit: let credit?):
                        SoundCreditRows(credit: credit)
                    case .loop(_, credit: nil):
                        Text("Creato da Sbu Noise, in loop senza stacchi")
                    }
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
    Color.clear.sheet(isPresented: .constant(true)) { SoundInfoSheet(sound: Sound.catalog.last ?? Sound.generated[0]) }
        .preferredColorScheme(.dark)
}
