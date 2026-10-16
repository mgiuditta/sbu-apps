import SbuKit
import SwiftUI

/// Tody's preset list for a room: "Base" and "Speciali", each with its frequency and effort.
/// Chores the room already has are marked, not hidden, so a second one is still possible.
struct PresetPicker: View {
    let kind: RoomKind
    let existing: [String]
    let pick: (ChorePreset) -> Void

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        List {
            if !kind.basePresets.isEmpty {
                Section("Base") {
                    rows(kind.basePresets)
                }
            }
            Section("Speciali") {
                rows(kind.specialPresets)
            }
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
        .background(SbuTheme.surface)
        .navigationTitle("Suggerimenti")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func rows(_ presets: [ChorePreset]) -> some View {
        ForEach(presets, id: \.self) { preset in
            Button {
                choose(preset)
            } label: {
                PresetRow(preset: preset, isInRoom: existing.contains(String(localized: preset.name)))
            }
            .listRowBackground(SbuTheme.surfaceRaised)
            .accessibilityIdentifier("preset")
        }
    }

    private func choose(_ preset: ChorePreset) {
        pick(preset)
        dismiss()
    }
}

/// A suggestion: name, frequency and effort, and a check when the room already has it.
private struct PresetRow: View {
    let preset: ChorePreset
    let isInRoom: Bool

    var body: some View {
        HStack(spacing: SbuTheme.space3) {
            VStack(alignment: .leading, spacing: SbuTheme.space1) {
                Text(preset.name)
                    .font(SbuTheme.body)
                    .foregroundStyle(SbuTheme.ink)
                Text(preset.frequency.text)
                    .font(SbuTheme.subheadline)
                    .foregroundStyle(SbuTheme.inkMuted)
            }
            Spacer(minLength: 0)
            if isInRoom {
                Image(systemName: "checkmark")
                    .fontWeight(.medium)
                    .foregroundStyle(SbuTheme.inkMuted)
                    .accessibilityLabel("Già nella stanza")
            }
            EffortDots(effort: preset.effort)
        }
        .accessibilityElement(children: .combine)
    }
}

#Preview("Light") {
    NavigationStack {
        PresetPicker(kind: .kitchen, existing: ["Lavare i piatti"]) { _ in }
    }
    .tint(SbuTheme.accentTidy)
}

#Preview("Dark") {
    NavigationStack {
        PresetPicker(kind: .kitchen, existing: []) { _ in }
    }
    .tint(SbuTheme.accentTidy)
    .preferredColorScheme(.dark)
}
