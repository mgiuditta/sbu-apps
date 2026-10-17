import SbuKit
import SwiftUI

/// Arrows around OK, as on the physical remote. Each arrow is its own labelled button.
struct DPadView: View {
    let session: RemoteSession

    var body: some View {
        VStack(spacing: SbuTheme.space2) {
            RemoteKeyButton(key: .up, session: session)
            HStack(spacing: SbuTheme.space2) {
                RemoteKeyButton(key: .left, session: session)
                RemoteKeyButton(key: .select, session: session, side: SbuTheme.controlRound)
                RemoteKeyButton(key: .right, session: session)
            }
            RemoteKeyButton(key: .down, session: session)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview("Light") {
    DPadView(session: .preview)
        .tint(SbuTheme.ink)
}

#Preview("Dark") {
    DPadView(session: .preview)
        .tint(SbuTheme.ink)
        .preferredColorScheme(.dark)
}
