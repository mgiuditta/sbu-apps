import SbuKit
import SwiftUI

/// One of your devices in the list: its ring and percentage when heard, "Non nelle vicinanze"
/// when not. Both open the finder.
struct MyDeviceLink: View {
    let saved: SavedDevice
    let heard: NearbyDevice?

    var body: some View {
        NavigationLink(value: heard?.id ?? saved.deviceID) {
            if let heard {
                DeviceRow(device: heard, savedName: saved.name)
            } else {
                AbsentDeviceRow(saved: saved)
            }
        }
    }
}

#Preview("Light") {
    NavigationStack {
        List {
            MyDeviceLink(
                saved: SavedDevice(name: "Le mie cuffie", device: NearbyDevice(id: UUID(), name: "WH-1000XM5", kind: .headphones, signal: -60, lastSeen: .now)),
                heard: NearbyDevice(id: UUID(), name: "WH-1000XM5", kind: .headphones, signal: -60, lastSeen: .now)
            )
        }
    }
}

#Preview("Dark") {
    NavigationStack {
        List {
            MyDeviceLink(
                saved: SavedDevice(name: "Le mie cuffie", device: NearbyDevice(id: UUID(), name: "WH-1000XM5", kind: .headphones, signal: -60, lastSeen: .now)),
                heard: nil
            )
        }
    }
    .preferredColorScheme(.dark)
}
