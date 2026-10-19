import SbuKit
import SwiftUI

/// A tool under the grid: an SF Symbol over a word. `isOn` inverts it, paper on ink.
struct ActionButton: View {
    let title: LocalizedStringKey
    let systemImage: String
    var isOn = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: SbuTheme.space1) {
                Image(systemName: systemImage)
                    .font(.title3.weight(.medium))
                    .frame(width: SbuTheme.controlRoundSm, height: SbuTheme.space8)
                    .foregroundStyle(isOn ? SbuTheme.paper : SbuTheme.ink)
                    .background(isOn ? SbuTheme.ink : .clear, in: .rect(cornerRadius: SbuTheme.radiusCard))
                Text(title)
                    .font(.caption)
                    .foregroundStyle(SbuTheme.ink)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
            .frame(maxWidth: .infinity, minHeight: SbuTheme.controlRoundSm)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isOn ? .isSelected : [])
    }
}

#Preview("Light") {
    HStack {
        ActionButton(title: "Annulla", systemImage: "arrow.uturn.backward") {}
        ActionButton(title: "Note", systemImage: "pencil", isOn: true) {}
    }
    .padding()
    .sbuPaper()
}

#Preview("Dark") {
    ActionButton(title: "Note", systemImage: "pencil", isOn: true) {}
        .padding()
        .sbuPaper()
        .preferredColorScheme(.dark)
}
