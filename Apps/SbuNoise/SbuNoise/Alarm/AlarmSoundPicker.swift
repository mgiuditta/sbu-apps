import SbuKit
import SwiftUI

/// The alarm's sound: the tones made for waking, then the whole catalog by group.
struct AlarmSoundPicker: View {
    let sounds: [Sound]
    @Binding var selection: String

    /// One column for the symbols, so the names line up.
    @ScaledMetric(relativeTo: .body) private var iconWidth = SbuTheme.space8

    var body: some View {
        List {
            Section("Suoni di sveglia") {
                ForEach(Sound.alarmTones) { sound in
                    row(sound)
                }
            }
            ForEach(SoundCategory.allCases) { group in
                Section {
                    ForEach(sounds.filter { $0.category == group }) { sound in
                        row(sound)
                    }
                } header: {
                    Text(group.title)
                }
            }
        }
        .navigationTitle("Suono")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func row(_ sound: Sound) -> some View {
        let isSelected = selection == sound.id
        return Button {
            selection = sound.id
        } label: {
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
            .contentShape(.rect)
        }
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

#Preview("Light") {
    NavigationStack { AlarmSoundPicker(sounds: Sound.catalog, selection: .constant("alarm.chimes")) }
}

#Preview("Dark") {
    NavigationStack { AlarmSoundPicker(sounds: Sound.catalog, selection: .constant("noise.pink")) }
        .preferredColorScheme(.dark)
}
