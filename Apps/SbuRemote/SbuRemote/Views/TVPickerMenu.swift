import SbuKit
import SwiftUI

/// The current TV's name beside its status; tapping it switches to another saved TV or adds one.
struct TVPickerMenu: View {
    let session: RemoteSession
    let onAdd: () -> Void

    var body: some View {
        Menu {
            ForEach(session.store.tvs) { tv in
                Button {
                    switchTo(tv)
                } label: {
                    if tv.id == session.tv?.id {
                        Label(tv.name, systemImage: "checkmark")
                    } else {
                        Text(tv.name)
                    }
                }
            }
            Divider()
            Button("Aggiungi una TV", systemImage: "plus", action: onAdd)
        } label: {
            HStack(spacing: SbuTheme.space1) {
                Text(session.tv?.name ?? "")
                    .font(SbuTheme.headline)
                    .foregroundStyle(SbuTheme.ink)
                Image(systemName: "chevron.down")
                    .font(SbuTheme.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(SbuTheme.inkMuted)
                    .accessibilityHidden(true)
            }
            .frame(minHeight: SbuTheme.controlRoundSm)
        }
        .accessibilityLabel(Text(session.tv?.name ?? ""))
        .accessibilityHint(Text("Cambia TV"))
    }

    private func switchTo(_ tv: SavedTV) {
        Task { await session.switchTo(tv) }
    }
}

#Preview("Light") {
    TVPickerMenu(session: .preview) {}
        .padding(SbuTheme.space4)
        .tint(SbuTheme.ink)
}

#Preview("Dark") {
    TVPickerMenu(session: .preview) {}
        .padding(SbuTheme.space4)
        .tint(SbuTheme.ink)
        .preferredColorScheme(.dark)
}
