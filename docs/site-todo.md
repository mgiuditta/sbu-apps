# Sito: cosa cambiare per la punta di lancia (15 ottobre 2026)

Il sito è in questa repo (`Site/`, Astro), ma oggi non l'ho toccato: ogni modifica sotto ha un blocco tecnico o una regola contraria. Qui cosa fare, in che ordine e con quale vincolo.

## 1. `/apps/auth` e `/privacy/auth`

Oggi impossibile: una pagina app esiste solo con un listing (`Apps/SbuAuth/fastlane/metadata`) e un'icona (`Design/icons/sbu-auth.png`), e `getUpcoming()` lancia un errore se manca l'icona (`Site/src/lib/apps.ts`). Auth non ha ancora né l'una né l'altro.

Quando parte lo sviluppo:
1. `Tools/new_app.sh Auth accent-authenticator "<strumento>"` (il token `accent-authenticator` esiste già in `Design/tokens.json`). Soggetto dell'incisione in `Design/icons/engravings.json`, poi `Tools/make_icons.py`.
2. `Site/src/content/apps/auth.md` sul modello di `clean.md`: `status: building`, `originale: { name: "Authenticator ℠ App", appStoreId: 6754900760 }`, `figure` (un codice di esempio, per esempio `482 913`, label "Codice"), `teaser`, `permissions` (Fotocamera solo per i QR), FAQ da `specs/auth/spec.json` (backup, cambio telefono, perché niente iCloud).
3. Con il listing compilato la pagina `/apps/auth` e `/privacy/auth` nascono da sole.

`/apps/clean` è già pronta (`status: building`). Al via libera di Apple: `appStoreId` e `status: live`.

## 2. Il bottone "Avvisami"

**Non si fa come raccolta di email.** `docs/marketing/marketing-plan.md` l'ha scartato: una lista di email è un dato personale e un account travestito, e il sito non ha script né form. Alternative coerenti, in ordine:
- link al feed RSS del blog (da aggiungere: `@astrojs/rss`, nessuna richiesta di terze parti), con un post al giorno 0 di ogni app;
- link a "Watch → Releases" della repo GitHub, quando è pubblica;
- nessun bottone: lo stato "In arrivo" sulla home basta.

Decisione di Matteo; consiglio il feed RSS.

## 3. "Il numero" sulla home e su `/principi`

Rimandato al giorno 0 di Auth. Prima di allora la home mostrerebbe prezzi di app che Sbu non ha ancora pubblicato, e il piano precedente aveva già deciso di aspettare 4-5 app live per "Il conto". Quando si fa:
- un componente sul modello di `SubscriptionCost.astro` (`/abbonamenti`): quattro righe testuali (nome dell'originale, settimanale "fino a", × 52) e il totale come unica cifra (`Stat.astro`, chiusa dal punto fermo: è la sola cifra della sezione);
- solo testo, nessuna icona o screenshot dei concorrenti, uso nominativo, data di lettura accanto ("prezzi di listino letti il …");
- i prezzi in un solo file di contenuto, con la data, come `originale.price` + `checked` (lo schema obbliga già la coppia);
- su `/principi` un paragrafo che collega il numero alla promessa "nessun abbonamento";
- solo le app con un'App Sbu pubblicata. Heartica resta fuori finché non c'è un'app Sbu per il battito.

## 4. `/alternatives/authenticator-app` (giorno 2)

`Site/src/content/alternatives/{it,en}/authenticator-app.md` con `draft: false`, `checked: <data>`, `facts` (prezzo, acquisti in-app, account, rete, backup, import da Google Authenticator). Si costruisce solo con Auth `live` (regola esistente).

## 5. Per Clean al via libera

`/alternatives/cleanup` sullo stesso modello, `status: live`, `appStoreId`.
