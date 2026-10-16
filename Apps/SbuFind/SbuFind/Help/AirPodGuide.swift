import Foundation

/// How to find a single earbud, step by step: the one the reviews of Wunderfind ask for.
nonisolated enum AirPodGuide {
    /// The steps in order; the last one opens Find My for Apple products.
    static let steps: [HelpItem] = [
        HelpItem(id: 1, systemImage: "airpods.chargingcase", text: "Rimetti nella custodia l'auricolare che hai e chiudila: così smette di trasmettere e non confonde la ricerca."),
        HelpItem(id: 2, systemImage: "figure.walk", text: "Porta la custodia lontano, in un'altra stanza."),
        HelpItem(id: 3, systemImage: "antenna.radiowaves.left.and.right", text: "In Sbu Find tocca Cerca di nuovo: l'auricolare perso compare solo se è fuori dalla custodia e ha un po' di carica."),
        HelpItem(id: 4, systemImage: "airpod.right", text: "Aprilo e cammina piano: la percentuale e il tic crescono quando ti avvicini."),
        HelpItem(id: 5, systemImage: "map", text: "Se non compare, forse è scarico: cerca dove l'hai usato l'ultima volta. Con Ricorda dove li hai sentiti, Sbu Find te lo mostra sulla mappa."),
        HelpItem(id: 6, systemImage: "location", text: "Se è un AirPod, in Dov'è puoi farlo suonare da solo: scegli il sinistro o il destro."),
    ]
}
