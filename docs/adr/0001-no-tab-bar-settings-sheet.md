# Niente tab bar: una NavigationStack e le Impostazioni in un foglio

Ogni **App Sbu** fa una **Cosa sola**, quindi `SbuAppShell` è una `NavigationStack` con l'unica schermata dell'app e un ingranaggio che apre le Impostazioni in un foglio, dove stanno sempre in fondo il **FreeBadge** e il link a sbu.dev. Una tab bar con due voci (contenuto, Impostazioni) avrebbe dato peso pari a una schermata secondaria, e la `Tab` API di SwiftUI richiede iOS 18 (vedi ADR-0002). Se un'app sembra aver bisogno di una seconda tab, è il segnale che sta facendo più di una cosa.
