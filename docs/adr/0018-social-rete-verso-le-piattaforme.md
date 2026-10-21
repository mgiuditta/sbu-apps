# Sbu Social: la rete solo verso i siti delle Piattaforme

Sbu Social apre i siti web delle **Piattaforme** dentro l'app, quindi fa chiamate di rete, che le regole di prodotto vietano salvo eccezioni (ADR-0007, 0008, 0009). Questa è la quarta eccezione, solo per Sbu Social, con questi confini:

- La webview di una Piattaforma apre come pagina solo i domini elencati per lei in `rules.json` (il sito e il suo login, per esempio `instagram.com`, `youtube.com`, `accounts.google.com`); immagini e video dei CDN si caricano solo dentro quelle pagine. Ogni altra pagina si apre in Safari, e solo se è http o https; tracker e domini pubblicitari di terzi sono bloccati con `WKContentRuleList`.
- Ogni **Account** ha il suo `WKWebsiteDataStore` sul telefono: cookie e sessione restano lì e si cancellano quando togli l'Account. Sbu non ha server, l'app non contiene SDK di terzi e l'etichetta privacy resta "Data Not Collected".
- Le **Regole** sono dentro l'app e cambiano solo con un aggiornamento: niente download (linea guida 2.5.2).
- Fuori dalla webview l'app chiama solo due cose, sempre verso le Piattaforme: i feed RSS dei canali YouTube che segui, e il controllo dei messaggi di Instagram e Snapchat in background quando accendi le notifiche (spente di default).

Motivo: Sbu Social è la stessa app di SocialLite (ADR-0017) e senza i siti delle Piattaforme non esiste. I confini tengono la promessa che conta, "dati solo sul dispositivo": i dati vanno solo tra il tuo telefono e i social che usi già, mai a Sbu o a terzi. Alternative scartate: un server Sbu per notifiche o login (rompe la promessa) e le Regole scaricate dalla rete (più veloci da aggiornare, ma vietate dalla 2.5.2). Nessun'altra app può usare questa eccezione senza un nuovo ADR.
