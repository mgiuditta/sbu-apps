import SbuKit
import SwiftUI

/// One tag on sunken paper; with a remove action in the form.
struct TagChip: View {
    let tag: String
    var remove: (() -> Void)?

    var body: some View {
        let label = HStack(spacing: SbuTheme.space1) {
            Text(tag)
                .foregroundStyle(SbuTheme.ink)
            if remove != nil {
                Image(systemName: "xmark")
                    .fontWeight(.medium)
                    .imageScale(.small)
                    .foregroundStyle(SbuTheme.inkMuted)
            }
        }
        .font(SbuTheme.subheadline)
        .padding(.horizontal, SbuTheme.space3)
        .padding(.vertical, SbuTheme.space1)
        .background(SbuTheme.surfaceSunken, in: .rect(cornerRadius: SbuTheme.radiusPill))

        if let remove {
            Button(action: remove) { label }
                .buttonStyle(.plain)
                .accessibilityLabel(Text("Rimuovi il tag \(tag)"))
        } else {
            label
        }
    }
}

#Preview("Light") {
    HStack {
        TagChip(tag: "attrezzi")
        TagChip(tag: "garage") {}
    }
    .padding(SbuTheme.space4)
}

#Preview("Dark") {
    HStack {
        TagChip(tag: "attrezzi")
        TagChip(tag: "garage") {}
    }
    .padding(SbuTheme.space4)
    .preferredColorScheme(.dark)
}
