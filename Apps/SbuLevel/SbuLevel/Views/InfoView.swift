import SbuKit
import SwiftUI

/// How Sbu Level works: the modes, calibration, the units and the limits of the sensor.
struct InfoView: View {
    var body: some View {
        List {
            Group {
                Section("Modalità") {
                    InfoRow(title: "Sul bordo", systemImage: "rectangle.portrait", text: "Appoggia un bordo dell'iPhone sulla superficie: il quadrante legge l'angolo di quel bordo, da 0° a 90°. I quattro bordi si riconoscono da soli.")
                    InfoRow(title: "In piano", systemImage: "circle.circle", text: "Appoggia l'iPhone sul retro: la bolla mostra la pendenza della superficie, e sotto c'è l'inclinazione lungo ciascun asse.")
                    InfoRow(title: "Mirino", systemImage: "camera.viewfinder", text: "Tocca Mirino e inquadra un punto lontano, il colmo di un tetto o la cima di un albero: la cifra è l'angolo della linea di mira sopra o sotto l'orizzonte. L'immagine non viene salvata.")
                }

                Section("Misurare") {
                    InfoRow(title: "Azzera qui", systemImage: "angle", text: "Prende la posizione attuale come zero: la cifra mostra di quanto ti sposti da lì. Assoluto torna all'angolo vero.")
                    InfoRow(title: "Blocca", systemImage: "lock", text: "Ferma la cifra, così la leggi anche dopo aver tolto l'iPhone. Con Blocca a lettura stabile aspetta che l'iPhone resti fermo e mostra la media.")
                    InfoRow(title: "Quadrante", systemImage: "arrow.clockwise", text: "Trascina il quadrante di un quarto di giro per leggere 0° sui lati invece che in alto e in basso. Un tocco nasconde i controlli, un altro li mostra.")
                }

                Section("Calibrazione") {
                    InfoRow(title: "Due misure per lato", systemImage: "level", text: "Ogni lato si calibra a parte: misura, gira l'iPhone di 180° sullo stesso punto e misura ancora. Le due misure si compensano, quindi la superficie non deve essere in bolla.")
                }

                Section("Unità") {
                    InfoRow(title: "Gradi", systemImage: "number", text: "L'angolo dall'orizzontale, al decimo o intero.")
                    InfoRow(title: "Pendenza in %", systemImage: "percent", text: "Quanto sale ogni 100 di base: 100 % è 45°. A 90° non ha valore e la cifra mostra un trattino.")
                    InfoRow(title: "x:12", systemImage: "house", text: "Quanto sale ogni 12 di base, come si misura un tetto.")
                    InfoRow(title: "1V:H", systemImage: "chart.line.uptrend.xyaxis", text: "Quanta base per 1 di alzata, come si scrive una scarpata.")
                }

                Section("Precisione") {
                    InfoRow(title: "I limiti del sensore", systemImage: "exclamationmark.triangle", text: "Il sensore dell'iPhone legge il decimo di grado, ma la misura vale quanto la calibrazione e l'appoggio: una custodia o una fotocamera sporgente cambiano l'angolo. Per lavori che chiedono uno strumento certificato, usa quello.")
                }
            }
            .listRowBackground(SbuTheme.surfaceRaised)
        }
        .scrollContentBackground(.hidden)
        .background(SbuTheme.surface)
        .navigationTitle("Come si usa")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview("Light") {
    NavigationStack {
        InfoView()
    }
}

#Preview("Dark") {
    NavigationStack {
        InfoView()
    }
    .preferredColorScheme(.dark)
}
