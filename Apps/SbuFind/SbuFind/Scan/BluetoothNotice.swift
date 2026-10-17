import Foundation

/// What the screen says when the scan cannot run: a title, a sentence, and whether
/// opening the app's page in Settings can fix it.
nonisolated struct BluetoothNotice: Equatable, Sendable {
    let title: LocalizedStringResource
    let message: LocalizedStringResource
    /// Only where the app's page in Settings has the switch: Bluetooth's power is in Control Center.
    let opensSettings: Bool

    /// `nil` when Bluetooth is ready and the list shows.
    init?(state: BluetoothState) {
        switch state {
        case .ready:
            return nil
        case .starting:
            title = "Avvio del Bluetooth"
            message = "Se te lo chiede, consenti il Bluetooth: serve per sentire i dispositivi vicini."
            opensSettings = false
        case .resetting:
            title = "Bluetooth in riavvio"
            message = "Torna da solo tra qualche secondo."
            opensSettings = false
        case .unsupported:
            title = "Bluetooth non disponibile"
            message = "Questo dispositivo non ha il Bluetooth Low Energy che serve per sentire i dispositivi vicini."
            opensSettings = false
        case .denied:
            title = "Bluetooth non consentito"
            message = "Per sentire i dispositivi vicini, consenti il Bluetooth a Sbu Find in Impostazioni. Quello che sente resta sull'iPhone."
            opensSettings = true
        case .restricted:
            title = "Bluetooth limitato"
            message = "Il Bluetooth per Sbu Find è bloccato da Tempo di utilizzo o da un profilo. Chiedi a chi gestisce questo iPhone."
            opensSettings = true
        case .poweredOff:
            title = "Bluetooth spento"
            message = "Accendilo dal Centro di Controllo o in Impostazioni, poi torna qui."
            opensSettings = false
        }
    }
}
