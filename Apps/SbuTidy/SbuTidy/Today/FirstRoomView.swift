import SbuKit
import SwiftUI

/// The first run, as Tody's: start from the rooms most homes have, or add your own.
struct FirstRoomView: View {
    /// The rooms of "Usa le stanze di base", in this order.
    static let baseRooms: [RoomKind] = [.kitchen, .bathroom, .bedroom, .livingRoom]

    let addRoom: () -> Void
    let addBaseRooms: () -> Void

    var body: some View {
        // Scrolls at the largest text sizes rather than pushing the buttons off screen.
        GeometryReader { proxy in
            ScrollView {
                content
                    .frame(minHeight: proxy.size.height)
            }
            .scrollBounceBehavior(.basedOnSize)
        }
        .background(SbuTheme.surface)
    }

    private var content: some View {
        VStack(alignment: .leading, spacing: SbuTheme.space4) {
            Spacer()
            Text("Inizia dalle stanze")
                .font(SbuTheme.title2)
                .foregroundStyle(SbuTheme.ink)
                .fixedSize(horizontal: false, vertical: true)
            Text("Ogni stanza arriva con le sue attività di base. Le cambi quando vuoi.")
                .font(SbuTheme.body)
                .foregroundStyle(SbuTheme.inkMuted)
                .fixedSize(horizontal: false, vertical: true)
            Spacer()
            SbuButton("Usa le stanze di base", action: addBaseRooms)
                .accessibilityIdentifier("addBaseRooms")
            SbuButton("Aggiungi una stanza", kind: .secondary, action: addRoom)
                .accessibilityIdentifier("addFirstRoom")
        }
        .padding(SbuTheme.space4)
        .frame(maxWidth: .infinity)
    }
}

#Preview("Light") {
    FirstRoomView(addRoom: {}, addBaseRooms: {})
        .tint(SbuTheme.accentTidy)
}

#Preview("Dark") {
    FirstRoomView(addRoom: {}, addBaseRooms: {})
        .tint(SbuTheme.accentTidy)
        .preferredColorScheme(.dark)
}
