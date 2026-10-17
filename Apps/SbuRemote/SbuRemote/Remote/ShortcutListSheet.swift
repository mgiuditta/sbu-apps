import SbuKit
import SwiftUI

/// A list of the TV's own items (inputs or apps) as text with one generic SF Symbol, never a logo.
/// Tapping one runs it on the TV and closes the sheet.
struct ShortcutListSheet: View {
    let title: LocalizedStringKey
    let systemImage: String
    let items: [TVShortcut]
    let onPick: (TVShortcut) -> Void

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List(items) { item in
                Button {
                    onPick(item)
                    dismiss()
                } label: {
                    Label {
                        Text(item.name)
                            .font(SbuTheme.body)
                            .foregroundStyle(SbuTheme.ink)
                    } icon: {
                        Image(systemName: systemImage)
                            .fontWeight(.medium)
                    }
                }
                .listRowBackground(SbuTheme.surfaceRaised)
            }
            .listStyle(.insetGrouped)
            .scrollContentBackground(.hidden)
            .background(SbuTheme.paper)
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Fine", action: close)
                }
            }
        }
        .presentationDetents([.medium, .large])
    }

    private func close() {
        dismiss()
    }
}

#Preview("Light") {
    ShortcutListSheet(title: "Sorgente", systemImage: "rectangle.on.rectangle", items: [TVShortcut(id: "1", name: "HDMI 1"), TVShortcut(id: "2", name: "PlayStation")]) { _ in }
        .tint(SbuTheme.ink)
}

#Preview("Dark") {
    ShortcutListSheet(title: "Sorgente", systemImage: "rectangle.on.rectangle", items: [TVShortcut(id: "1", name: "HDMI 1"), TVShortcut(id: "2", name: "PlayStation")]) { _ in }
        .tint(SbuTheme.ink)
        .preferredColorScheme(.dark)
}
