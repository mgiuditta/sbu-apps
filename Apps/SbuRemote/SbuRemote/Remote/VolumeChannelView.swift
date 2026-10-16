import SbuKit
import SwiftUI

/// Volume on the left, channel on the right, mute and source between them. Held keys repeat.
struct VolumeChannelView: View {
    let session: RemoteSession
    var onInputs: ([TVShortcut]) -> Void = { _ in }

    var body: some View {
        HStack(alignment: .center) {
            RockerView(title: "Volume", up: .volumeUp, down: .volumeDown, session: session)
            Spacer()
            VStack(spacing: SbuTheme.space2) {
                RemoteKeyButton(key: .mute, session: session)
                SourceButton(session: session, onInputs: onInputs)
            }
            Spacer()
            RockerView(title: "Canale", up: .channelUp, down: .channelDown, session: session)
        }
    }
}

#Preview("Light") {
    VolumeChannelView(session: .preview)
        .padding(SbuTheme.space4)
        .tint(SbuTheme.accentRemote)
}

#Preview("Dark") {
    VolumeChannelView(session: .preview)
        .padding(SbuTheme.space4)
        .tint(SbuTheme.accentRemote)
        .preferredColorScheme(.dark)
}
