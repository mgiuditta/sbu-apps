# Niente tab bar: una NavigationStack e le Impostazioni in un foglio

Ogni **App Sbu** fa una **Cosa sola**, quindi `SbuAppShell` è una `NavigationStack` che parte dalla **Schermata strumento**, con un ingranaggio che apre le Impostazioni in un foglio, dove stanno sempre in fondo il **FreeBadge** e il link a sbu.dev. Una tab bar con due voci (contenuto, Impostazioni) avrebbe dato peso pari a una schermata secondaria, e la `Tab` API di SwiftUI richiede iOS 18 (vedi ADR-0002). Se un'app sembra aver bisogno di una seconda tab, è il segnale che sta facendo più di una cosa.

Un'app con una seconda area di gestione allo stesso livello (per esempio elenco e storico in Sbu Subscriptions) può avere una tab bar, ma solo con un ADR che sostituisce questo per quell'app.
