# L'archivio di Sbu Docs è fatto di file PDF, non di un database

In Sbu Docs ogni documento è un file PDF nella cartella dell'app, visibile nell'app File, con il testo riconosciuto come livello invisibile; non c'è un database. Il dolore più grave nelle recensioni dell'**Originale** sono i documenti persi o inaccessibili dopo un aggiornamento, un cambio di telefono o un abbonamento scaduto: con i file restano tuoi anche senza l'app, entrano nel backup dell'iPhone e non richiedono migrazioni.

## Considered Options

- Database SwiftData con l'immagine originale di ogni pagina e annotazioni modificabili (il modello dati dello **Spec**), PDF generato solo all'export. Scartato: i documenti vivono solo dentro l'app.

## Consequences

- Le pagine non conservano l'immagine originale: niente "riritaglia" o "cambia filtro" dopo il salvataggio. Si elimina la pagina e la si riscansiona.
- File aggiunti, rinominati o cancellati dall'app File sono la verità: l'elenco li rilegge, non li sincronizza.
