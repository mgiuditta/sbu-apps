import SbuKit
import SwiftUI

/// An Abitudine condivisa received, on the tool screen: its ring as the owner's day stands, with
/// the owner's badge on the ring's bottom right. Read only: holding it only says so, a tap opens
/// its screen with the statistics.
struct SharedHabitCell: View {
    /// How long to hold, as on the user's own habits.
    private static let holdDuration = 0.5
    /// How long the notice stays after a hold.
    private static let noticeDuration = Duration.seconds(2.5)

    let display: SharedHabitDisplay
    /// The ring's largest side: `.infinity` on a page of the grid, where the place sets it.
    var maxRingSide = CGFloat.infinity
    /// The captions of the cell's page in the grid, so the rings of a page stay even.
    var pageCaptions: [SlotCaption] = []
    let open: () -> Void

    @State private var isShowingNotice = false

    static func caption(of display: SharedHabitDisplay) -> SlotCaption {
        SlotCaption(title: Text(display.habit.title))
    }

    private var accessibilityValue: Text {
        display.face.progressText + Text(verbatim: ", ") + Text(display.habit.schedule.streakText(display.streak))
            + Text(verbatim: ", ") + Text("condivisa da un'altra persona")
    }

    var body: some View {
        RingSlot(maxRingSide: maxRingSide, caption: Self.caption(of: display), pageCaptions: pageCaptions) {
            HabitRing(face: display.face)
        }
        .overlayPreferenceValue(RingBoundsKey.self) { anchor in
            if let anchor {
                GeometryReader { proxy in
                    let ring = proxy[anchor]
                    // On the ring's stroke, at the bottom right, where a timed habit has play.
                    let offset = RingBadgeSize.offset(inRingOfSide: ring.width)
                    OwnerBadge(emoji: display.ownerEmoji, side: RingBadgeSize.side(forRingSide: ring.width))
                        .position(x: ring.midX + offset, y: ring.midY + offset)
                }
            }
        }
        .overlay(alignment: .bottom) {
            if isShowingNotice {
                Text("Condivisa da un'altra persona: solo da vedere")
                    .font(SbuTheme.footnote)
                    // Over the ring of a cell: past the first accessibility size it would not fit.
                    .dynamicTypeSize(...DynamicTypeSize.accessibility1)
                    .foregroundStyle(SbuTheme.ink)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, SbuTheme.space3)
                    .padding(.vertical, SbuTheme.space2)
                    .background(SbuTheme.surfaceRaised, in: .rect(cornerRadius: SbuTheme.radiusMd))
                    .transition(.opacity)
                    .accessibilityHidden(true)
            }
        }
        .contentShape(.rect)
        .onTapGesture(perform: open)
        .onLongPressGesture(minimumDuration: Self.holdDuration, perform: showNotice)
        .sensoryFeedback(.warning, trigger: isShowingNotice) { _, new in new }
        .task(id: isShowingNotice) {
            guard isShowingNotice else { return }
            try? await Task.sleep(for: Self.noticeDuration)
            withAnimation {
                isShowingNotice = false
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(display.habit.title)
        .accessibilityValue(accessibilityValue)
        .accessibilityAddTraits(.isButton)
        .accessibilityAction(.default, open)
    }

    private func showNotice() {
        withAnimation {
            isShowingNotice = true
        }
    }
}

#Preview("Light") {
    SharedHabitCellPreview()
}

#Preview("Dark") {
    SharedHabitCellPreview()
        .preferredColorScheme(.dark)
}

private struct SharedHabitCellPreview: View {
    var body: some View {
        let received = ReceivedHabitsFile.demo(today: LogicalDay(.now)).habits[0]
        var withEmoji = received
        withEmoji.ownerEmoji = "😎"
        return HStack(spacing: SbuTheme.space3) {
            SharedHabitCell(display: SharedHabitDisplay(received, now: .now)) {}
            SharedHabitCell(display: SharedHabitDisplay(withEmoji, now: .now)) {}
        }
        .frame(height: SbuTheme.space12 * 4)
        .padding(SbuTheme.space4)
        .background(SbuTheme.surface)
        .tint(SbuTheme.accentHabits)
    }
}
