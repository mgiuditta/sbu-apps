import SbuKit
import SwiftUI

/// Settings section that opens the Info page.
struct InfoSection: View {
    var body: some View {
        Section {
            NavigationLink {
                InfoView()
            } label: {
                Label("Come si usa", systemImage: "info.circle")
            }
        }
    }
}

#Preview("Light") {
    NavigationStack {
        List {
            InfoSection()
        }
    }
}

#Preview("Dark") {
    NavigationStack {
        List {
            InfoSection()
        }
    }
    .preferredColorScheme(.dark)
}
