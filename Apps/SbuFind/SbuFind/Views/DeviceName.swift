import SwiftUI

/// A device's advertised name as it is, never translated; "Senza nome" when it says none.
struct DeviceName: View {
    let name: String?

    var body: some View {
        if let name {
            Text(verbatim: name)
        } else {
            Text("Senza nome")
        }
    }
}

#Preview("Light") {
    VStack {
        DeviceName(name: "Buds Pro")
        DeviceName(name: nil)
    }
}

#Preview("Dark") {
    VStack {
        DeviceName(name: "Buds Pro")
        DeviceName(name: nil)
    }
    .preferredColorScheme(.dark)
}
