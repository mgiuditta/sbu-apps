import SbuKit
import SwiftUI

/// One key of the remote: an SF Symbol on a raised paper key in ink, the tick on every press.
struct RemoteKeyButton: View {
    let key: RemoteKey
    let session: RemoteSession
    var side: CGFloat = SbuTheme.controlRoundSm

    @State private var presses = 0
    @State private var isHolding = false

    var body: some View {
        Button(action: press) {
            Image(systemName: key.systemImage)
                .fontWeight(.medium)
                .imageScale(.medium)
                .font(SbuTheme.headline)
                .frame(minWidth: side, minHeight: side)
        }
        .buttonStyle(.remoteKey)
        .disabled(!session.isAvailable(key))
        .accessibilityLabel(Text(key.title))
        .sbuHaptic(.tick, trigger: presses)
        .simultaneousGesture(LongPressGesture(minimumDuration: 0.4).onEnded { _ in beginHold() })
        .simultaneousGesture(DragGesture(minimumDistance: 0).onEnded { _ in endHold() })
    }

    private func press() {
        // The tap that ends a long press is not one more key.
        guard !isHolding else { return }
        presses += 1
        Task { await session.press(key) }
    }

    private func beginHold() {
        guard key.repeatsWhileHeld, session.isAvailable(key) else { return }
        isHolding = true
        Task { await session.beginHold(key) }
    }

    private func endHold() {
        guard isHolding else { return }
        Task {
            await session.endHold()
            isHolding = false
        }
    }
}
