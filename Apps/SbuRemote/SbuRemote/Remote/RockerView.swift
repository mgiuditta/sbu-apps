import SbuKit
import SwiftUI

/// A pair of keys stacked like the rocker of a physical remote, named underneath.
struct RockerView: View {
    let title: LocalizedStringKey
    let up: RemoteKey
    let down: RemoteKey
    let session: RemoteSession

    var body: some View {
        VStack(spacing: SbuTheme.space2) {
            RemoteKeyButton(key: up, session: session)
            Text(title)
                .font(SbuTheme.caption)
                .foregroundStyle(SbuTheme.inkMuted)
                .accessibilityHidden(true)
            RemoteKeyButton(key: down, session: session)
        }
    }
}
