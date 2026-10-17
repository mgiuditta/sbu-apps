import SbuKit
import SwiftUI

/// The kind of room, each with its symbol, in a pushed list like iOS's own pickers.
struct RoomKindPicker: View {
    @Binding var selection: RoomKind

    var body: some View {
        Picker("Tipo", selection: $selection) {
            ForEach(RoomKind.allCases) { kind in
                Label {
                    Text(kind.name)
                } icon: {
                    Image(systemName: kind.symbol)
                        .fontWeight(.medium)
                        .imageScale(.medium)
                }
                .tag(kind)
            }
        }
        .pickerStyle(.navigationLink)
        .accessibilityIdentifier("roomKind")
    }
}

#Preview("Light") {
    RoomKindPickerPreview()
}

#Preview("Dark") {
    RoomKindPickerPreview()
        .preferredColorScheme(.dark)
}

private struct RoomKindPickerPreview: View {
    @State private var kind = RoomKind.bathroom

    var body: some View {
        NavigationStack {
            Form {
                RoomKindPicker(selection: $kind)
            }
        }
        .environment(\.sbuAccent, .tidy)
    }
}
