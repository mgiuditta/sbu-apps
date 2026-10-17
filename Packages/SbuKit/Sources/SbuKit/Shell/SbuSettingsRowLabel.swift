// iOS only, like the settings it belongs to.
#if os(iOS)

import SwiftUI

/// A settings row that leaves the app: the title in `ink`, the symbol of where it goes in `inkMuted`.
struct SbuSettingsRowLabel: View {
    let title: Text
    let systemImage: String

    var body: some View {
        HStack {
            title
                .font(SbuTheme.body)
                .foregroundStyle(SbuTheme.ink)

            Spacer(minLength: 0)

            Image(systemName: systemImage)
                .fontWeight(.medium)
                .imageScale(.medium)
                .foregroundStyle(SbuTheme.inkMuted)
                .accessibilityHidden(true)
        }
    }
}

#Preview("Light") {
    List {
        SbuSettingsRowLabel(title: Text(verbatim: "Privacy"), systemImage: "arrow.up.right")
    }
}

#Preview("Dark") {
    List {
        SbuSettingsRowLabel(title: Text(verbatim: "Privacy"), systemImage: "arrow.up.right")
    }
    .preferredColorScheme(.dark)
}

#endif
