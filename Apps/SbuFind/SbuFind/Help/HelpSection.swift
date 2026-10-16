import Foundation

/// One section of the help page: a title and short sentences, each with its symbol.
nonisolated struct HelpSection: Identifiable, Sendable {
    let id: Int
    let title: LocalizedStringResource
    let items: [HelpItem]

    /// The section on a single AirPod: it leads to the step-by-step guide.
    static let singleAirPodID = 2

    /// Apple's Find My: it opens from the help page for Apple products.
    static let findMyURL = URL(string: "findmy://")

    /// What the help page says, in order: how to search, what the app cannot hear, a single
    /// AirPod, and when Find My does better.
    static let all: [HelpSection] = [
        HelpSection(id: 0, title: "Per ritrovarlo", items: [
            HelpItem(id: 0, systemImage: "power", text: "Il dispositivo deve essere acceso e fuori dalla custodia: Sbu Find sente solo quello che trasmette."),
            HelpItem(id: 1, systemImage: "figure.walk", text: "Cammina piano e fermati qualche secondo: il numero ha bisogno di un attimo per assestarsi."),
            HelpItem(id: 2, systemImage: "arrow.triangle.2.circlepath", text: "Gira su te stesso e tieni l'iPhone davanti a te: il tuo corpo e i muri abbassano il segnale."),
            HelpItem(id: 3, systemImage: "sofa", text: "A Qui vicino guarda sotto i cuscini, nelle borse e nelle tasche delle giacche."),
        ]),
        HelpSection(id: 1, title: "Cosa Sbu Find non sente", items: [
            HelpItem(id: 0, systemImage: "airpods.chargingcase", text: "AirPods nella custodia chiusa: non trasmettono finché la custodia è chiusa."),
            HelpItem(id: 1, systemImage: "battery.0percent", text: "Un dispositivo spento o con la batteria scarica."),
            HelpItem(id: 2, systemImage: "headphones", text: "Cuffie che usano solo il Bluetooth classico e non il Bluetooth Low Energy."),
            HelpItem(id: 3, systemImage: "ruler", text: "Oltre una decina di metri, e meno tra muri e metallo. Il numero dice quanto è forte il segnale, non quanto è lontano."),
        ]),
        HelpSection(id: 4, title: "Con l'app chiusa", items: [
            HelpItem(id: 0, systemImage: "moon.zzz", text: "Con l'app chiusa iOS lascia ascoltare solo i tuoi dispositivi che trasmettono un servizio Bluetooth, e li sente meno spesso: Avvisami se lo perdi aspetta più a lungo prima di avvisarti."),
            HelpItem(id: 1, systemImage: "airpods", text: "Gli AirPods e molte cuffie non trasmettono un servizio: si seguono solo con l'app aperta. Per loro, Dov'è di Apple fa di più."),
            HelpItem(id: 2, systemImage: "xmark.app", text: "Se chiudi Sbu Find dal selettore delle app, si ferma tutto finché non lo riapri."),
        ]),
        HelpSection(id: 2, title: "Se hai perso un solo AirPod", items: [
            HelpItem(id: 0, systemImage: "airpod.right", text: "Un AirPod trasmette solo fuori dalla custodia e con un po' di carica. In Dov'è puoi farlo suonare da solo, uno alla volta."),
        ]),
        HelpSection(id: 3, title: "Prodotti Apple", items: [
            HelpItem(id: 0, systemImage: "location", text: "Per AirPods, Apple Watch, iPhone, iPad e AirTag usa Dov'è di Apple: li fa suonare anche nella custodia o lontano, mostra dove li hai lasciati e li trova sulla rete Dov'è. Sbu Find fa suonare solo le cuffie collegate all'iPhone e non vede la rete Dov'è."),
        ]),
    ]
}
