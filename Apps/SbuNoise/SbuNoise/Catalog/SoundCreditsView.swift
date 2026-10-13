import SbuKit
import SwiftUI

/// Impostazioni → Crediti dei suoni: the source of every recording in the catalog, next to the
/// font licences of Licenze. CC0 asks for no credit; the authors are named anyway.
struct SoundCreditsView: View {
    let sounds: [Sound]

    var body: some View {
        List {
            Section {
                Text("Le registrazioni vengono da Freesound e sono in pubblico dominio (CC0): tagliate e chiuse in un loop senza stacchi. I rumori e gli altri suoni sono creati da Sbu Noise.")
                    .font(SbuTheme.footnote)
                    .foregroundStyle(SbuTheme.inkMuted)
            }
            ForEach(recorded, id: \.sound.id) { entry in
                Section {
                    SoundCreditRows(credit: entry.credit, showsNote: false)
                } header: {
                    Text(entry.sound.name)
                }
            }
            Section("Creati da Sbu Noise") {
                ForEach(made) { sound in
                    Text(sound.name)
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Crediti dei suoni")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var recorded: [(sound: Sound, credit: SoundCredit)] {
        sounds.compactMap { sound in sound.source.credit.map { (sound, $0) } }
    }

    private var made: [Sound] {
        sounds.filter { $0.source.credit == nil }
    }
}

#Preview("Light") {
    NavigationStack { SoundCreditsView(sounds: Sound.catalog) }
}

#Preview("Dark") {
    NavigationStack { SoundCreditsView(sounds: Sound.catalog) }
        .preferredColorScheme(.dark)
}
