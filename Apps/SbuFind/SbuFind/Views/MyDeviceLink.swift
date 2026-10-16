import SbuKit
import SwiftUI

/// One of your devices in the list: its ring and percentage when heard, "Non nelle vicinanze"
/// when not. Heard only under another identifier with your device's name, it says "Forse è il
/// tuo": any device can advertise that name. All open the finder.
struct MyDeviceLink: View {
    let saved: SavedDevice
    let match: DeviceMatch?

    var body: some View {
        NavigationLink(value: match?.device.id ?? saved.deviceID) {
            if let match {
                DeviceRow(device: match.device, savedName: saved.name, isProbable: !match.isByIdentifier)
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
                match: DeviceMatch(device: NearbyDevice(id: UUID(), name: "WH-1000XM5", kind: .headphones, signal: -60, lastSeen: .now), isByIdentifier: false)
            )
        }
    }
}

#Preview("Dark") {
    NavigationStack {
        List {
            MyDeviceLink(
                saved: SavedDevice(name: "Le mie cuffie", device: NearbyDevice(id: UUID(), name: "WH-1000XM5", kind: .headphones, signal: -60, lastSeen: .now)),
                match: nil
            )
        }
    }
    .preferredColorScheme(.dark)
}
