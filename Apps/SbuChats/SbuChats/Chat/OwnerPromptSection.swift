import SbuKit
import SwiftUI

/// "Chi sei?" not answered yet: the way to answer it, so your numbers stand apart.
struct OwnerPromptSection: View {
    let choose: () -> Void

    var body: some View {
        Section {
            Button(action: choose) {
                Label {
                    Text("Scegli chi sei")
                        .font(SbuTheme.body)
                        .foregroundStyle(SbuTheme.ink)
                } icon: {
                    Image(systemName: "person.crop.circle.badge.questionmark")
                        .fontWeight(.medium)
                        .foregroundStyle(SbuTheme.inkMuted)
                }
            }
        } footer: {
            Text("Così i tuoi numeri si separano da quelli degli altri.")
        }
        .listRowBackground(SbuTheme.surfaceRaised)
    }
}

#Preview("Light") {
    List { OwnerPromptSection {} }
}

#Preview("Dark") {
    List { OwnerPromptSection {} }
        .preferredColorScheme(.dark)
}
