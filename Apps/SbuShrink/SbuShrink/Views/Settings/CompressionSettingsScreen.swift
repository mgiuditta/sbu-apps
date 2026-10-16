import SbuKit
import SwiftUI

/// The original's "Compression Settings", in its order: frame rate, dimensions (plus the
/// competitor's quality), then the videos with their sizes and Comprimi. The estimate is the
/// figure, at the top so it moves under your eyes as the sliders do. The options the original
/// lacks wait closed in "Avanzate".
struct CompressionSettingsScreen: View {
    @Bindable var model: ShrinkModel

    var body: some View {
        List {
            Section {
                EstimateStat(model: model)
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
            }

            SettingSliderSection(
                title: "Frame rate",
                value: $model.settings.frameRate,
                range: CompressionSettings.frameRateRange,
                step: 1,
                valueText: Text("\(model.settings.frameRate) fps"),
                hint: "Più fotogrammi al secondo occupano più spazio. Ti consigliamo di non scendere sotto 24. Mai oltre quelli del video."
            )

            SettingSliderSection(
                title: "Dimensioni",
                value: $model.settings.dimensionPercent,
                range: CompressionSettings.dimensionRange,
                step: 5,
                valueText: Text(Double(model.settings.dimensionPercent) / 100, format: .percent),
                hint: "Riduci le dimensioni del video per risparmiare ancora più spazio. Ti consigliamo l'80%."
            )

            SettingSliderSection(
                title: "Qualità",
                value: $model.settings.qualityPercent,
                range: CompressionSettings.qualityRange,
                step: 5,
                valueText: Text(Double(model.settings.qualityPercent) / 100, format: .percent),
                hint: model.settings.targetMegabytes == nil
                    ? "Più qualità tiene più dettagli e occupa più spazio. Ti consigliamo il 60%."
                    : "Con la dimensione massima la qualità si regola da sola."
            )
            .disabled(model.settings.targetMegabytes != nil)

            AdvancedSection(settings: $model.settings, targetFit: model.targetFit)

            SelectedVideosSection(model: model)
        }
        .listStyle(.insetGrouped)
        .listSectionSpacing(.compact)
        .scrollContentBackground(.hidden)
        .scrollDismissesKeyboard(.interactively)
        .background(SbuTheme.surface)
        .navigationTitle("Compressione")
        .navigationBarTitleDisplayMode(.inline)
        .bottomAction {
            SbuButton("Comprimi", action: model.compress)
                .disabled(!model.canCompress)
        }
    }
}

#Preview("Light") {
    NavigationStack {
        CompressionSettingsScreen(model: .preview(videos: 5))
    }
    .tint(SbuTheme.accentShrink)
}

#Preview("Dark") {
    NavigationStack {
        CompressionSettingsScreen(model: .preview(videos: 5, scenario: "mixed"))
    }
    .tint(SbuTheme.accentShrink)
    .preferredColorScheme(.dark)
}
