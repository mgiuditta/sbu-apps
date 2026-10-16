import SbuKit
import SwiftUI

/// Volume on the left, channel on the right, mute between them. Held keys repeat.
struct VolumeChannelView: View {
    let session: RemoteSession
    /// The keys between the two rockers (mute, then whatever the screen adds).
    var middle: [RemoteKey] = [.mute]

    var body: some View {
        HStack(alignment: .center) {
            RockerView(title: "Volume", up: .volumeUp, down: .volumeDown, session: session)
            Spacer()
            VStack(spacing: SbuTheme.space2) {
                ForEach(middle, id: \.self) { key in
                    RemoteKeyButton(key: key, session: session)
                }
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
