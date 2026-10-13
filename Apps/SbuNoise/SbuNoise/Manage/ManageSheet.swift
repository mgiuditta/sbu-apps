import SbuKit
import SwiftUI

/// Gestisci, from the bottom bar, as in the original: the catalog in the player's order. Tap a
/// sound to play it, drag to reorder, swipe to hide it or give it a heart, search and filter by
/// group. Hidden sounds stay in the list below: a tap puts them back.
struct ManageSheet: View {
    let model: PlayerModel

    @Environment(\.dismiss) private var dismiss
    @State private var query = ""
    @State private var group: SoundCategory?

    var body: some View {
        NavigationStack {
            List {
                if isFiltering {
                    Section {
                        ForEach(results) { sound in
                            row(sound)
                        }
                    } footer: {
                        if results.isEmpty {
                            Text("Nessun suono trovato.")
                        }
                    }
                } else {
                    Section {
                        ForEach(model.visibleSounds) { sound in
                            row(sound)
                        }
                        .onMove(perform: model.moveSounds)
                    } header: {
                        Text("Nel player")
                    } footer: {
                        Text("Tocca Modifica per cambiare l'ordine. Scorri un suono per nasconderlo, tocca un suono nascosto per rimetterlo.")
                    }
                    if !hidden.isEmpty {
                        Section("Nascosti") {
                            ForEach(hidden) { sound in
                                row(sound)
                            }
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
            .searchable(text: $query, placement: .navigationBarDrawer(displayMode: .always), prompt: Text("Cerca un suono"))
            .navigationTitle("Gestisci")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Fine") { dismiss() }
                }
                ToolbarItemGroup(placement: .primaryAction) {
                    GroupFilter(selection: $group)
                    if !isFiltering {
                        EditButton()
                    }
                }
            }
        }
    }

    private var isFiltering: Bool {
        group != nil || !query.trimmingCharacters(in: .whitespaces).isEmpty
    }

    private var hidden: [Sound] {
        model.arrangedSounds.filter(model.isHidden)
    }

    /// The sounds that match the search and the group, hidden ones included.
    private var results: [Sound] {
        let text = query.trimmingCharacters(in: .whitespaces)
        return model.arrangedSounds.filter { sound in
            (group == nil || sound.category == group)
                && (text.isEmpty || String(localized: sound.name).localizedStandardContains(text))
        }
    }

    private func row(_ sound: Sound) -> some View {
        let isHidden = model.isHidden(sound)
        let isFavorite = model.isFavorite(.sound(sound))
        return Button {
            if isHidden { model.show(sound) } else { play(sound) }
        } label: {
            ManageRow(sound: sound, isFavorite: isFavorite, isHidden: isHidden)
        }
        .swipeActions(edge: .trailing) {
            if isHidden {
                Button("Mostra", systemImage: "eye") { model.show(sound) }
            } else {
                Button("Nascondi", systemImage: "eye.slash") { model.hide(sound) }
            }
        }
        .swipeActions(edge: .leading) {
            Button(isFavorite ? "Togli dai preferiti" : "Aggiungi ai preferiti", systemImage: isFavorite ? "heart.slash" : "heart") {
                model.toggleFavorite(.sound(sound))
            }
            .tint(SbuTheme.accentNoise)
        }
        .accessibilityHint(isHidden ? Text("Lo rimette nel player.") : Text("Lo riproduce."))
    }

    private func play(_ sound: Sound) {
        model.playItem(withID: sound.id)
        dismiss()
    }
}

#Preview("Light") {
    ManageSheet(model: PlayerModel())
        .tint(SbuTheme.accentNoise)
}

#Preview("Dark") {
    ManageSheet(model: PlayerModel())
        .tint(SbuTheme.accentNoise)
        .preferredColorScheme(.dark)
}
