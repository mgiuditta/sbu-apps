import SbuKit
import SwiftUI

/// Chooses the sounds for a mix, up to the room left in it, group by group.
struct MixSoundPicker: View {
    let sounds: [Sound]
    let limit: Int
    let confirmTitle: LocalizedStringKey
    let onConfirm: ([String]) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var selection: [String] = []
    /// One column for the symbols, so the names line up.
    @ScaledMetric(relativeTo: .body) private var iconWidth = SbuTheme.space8

    var body: some View {
        List {
            Section {
                Text("Fino a \(limit) suoni.")
                    .font(SbuTheme.footnote)
                    .foregroundStyle(SbuTheme.inkMuted)
            }
            ForEach(groups, id: \.group) { entry in
                Section {
                    ForEach(entry.sounds) { sound in
                        let isSelected = selection.contains(sound.id)
                        Button {
                            if isSelected {
                                selection.removeAll { $0 == sound.id }
                            } else if selection.count < limit {
                                selection.append(sound.id)
                            }
                        } label: {
                            // ponytail: not a Label, which the accessibility audit flags as clipped in this row.
                            HStack(spacing: SbuTheme.space3) {
                                Image(systemName: sound.systemImage)
                                    .fontWeight(.medium)
                                    .frame(width: iconWidth)
                                    .accessibilityHidden(true)
                                Text(sound.name)
                                Spacer()
                                if isSelected {
                                    Image(systemName: "checkmark")
                                        .fontWeight(.medium)
                                        .foregroundStyle(.tint)
                                }
                            }
                            .foregroundStyle(SbuTheme.ink)
                        }
                        .disabled(!isSelected && selection.count >= limit)
                        .accessibilityAddTraits(isSelected ? .isSelected : [])
                    }
                } header: {
                    Text(entry.group.title)
                }
            }
        }
        .navigationTitle("Scegli i suoni")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Annulla") { dismiss() }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button(confirmTitle) { onConfirm(selection) }
                    .disabled(selection.isEmpty)
            }
        }
    }

    /// The catalog's groups that have sounds here, in catalog order.
    private var groups: [(group: SoundCategory, sounds: [Sound])] {
        SoundCategory.allCases.compactMap { group in
            let members = sounds.filter { $0.category == group }
            return members.isEmpty ? nil : (group, members)
        }
    }
}

#Preview("Light") {
    NavigationStack {
        MixSoundPicker(sounds: Sound.generated, limit: 5, confirmTitle: "Avanti") { _ in }
    }
}

#Preview("Dark") {
    NavigationStack {
        MixSoundPicker(sounds: Sound.generated, limit: 2, confirmTitle: "Aggiungi") { _ in }
    }
    .preferredColorScheme(.dark)
}
