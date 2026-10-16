// iOS only: the shell, the settings and list rows have no place on Apple Watch.
#if os(iOS)

import SwiftUI

/// One tab of `SbuTabShell`: a screen in its own NavigationStack on `paper`, with its name and symbol in the tab bar.
///
///     SbuTab("Calendario", systemImage: "calendar", value: AppTab.calendar) {
///         PaymentsCalendarView()
///     }
public struct SbuTab<Value: Hashable, Content: View>: View {
    private let title: LocalizedStringKey
    private let systemImage: String
    private let value: Value
    private let content: Content

    /// Creates a tab.
    /// - Parameters:
    ///   - title: The tab's name, shown in the tab bar and as the screen's inline navigation title.
    ///   - systemImage: The SF Symbol in the tab bar.
    ///   - value: The selection value that shows this tab.
    ///   - content: The tab's root screen.
    public init(_ title: LocalizedStringKey, systemImage: String, value: Value, @ViewBuilder content: () -> Content) {
        self.title = title
        self.systemImage = systemImage
        self.value = value
        self.content = content()
    }

    public var body: some View {
        NavigationStack {
            content
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                .background(SbuTheme.paper)
                .navigationTitle(title)
                .navigationBarTitleDisplayMode(.inline)
                .sbuFullStopAudit(String(describing: value))
        }
        .tabItem {
            Label(title, systemImage: systemImage)
        }
        .tag(value)
    }
}

#endif
