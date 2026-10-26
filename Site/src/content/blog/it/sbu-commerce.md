---
title: "Sbu Commerce: Spartacus su un backend open source"
description: Sbu Commerce v0.1.0 è un backend commerce open source che parla l’API OCC. Uno storefront Spartacus stock ci gira sopra senza modifiche.
date: 2026-11-10
draft: true
---

Se il tuo storefront è fatto con Spartacus, parla con il backend attraverso una sola API: OCC. Percorsi, `fields`, formato degli errori, login OAuth2. Tutto quello che lo storefront sa del backend passa da quel contratto.

Sbu Commerce è un backend che parla quel contratto. Ci ho puntato sopra uno storefront Spartacus stock, senza cambiare niente nello storefront, e ho fatto tutto il percorso B2C: home, ricerca, pagina prodotto, carrello, registrazione, login, checkout, storico ordini. Funziona.

Da oggi è pubblico: versione 0.1.0, licenza Apache-2.0, su GitHub.

## Perché l’ho fatto

Lavoro su progetti SAP Commerce e Spartacus. Chi vuole lasciare una piattaforma a licenza di solito si sente dire la stessa cosa: ripiattaformare. Backend nuovo vuol dire storefront nuovo, integrazioni nuove, mesi di lavoro. L’investimento sullo storefront si butta.

Non è obbligatorio. Se il backend parla la stessa API, cambi il server, non il sito.

## Cosa c’è nella 0.1.0

Più di quello che serve a uno storefront per partire:

- le 33 operazioni OCC di uno storefront Spartacus B2C, con le proiezioni `fields`, gli errori OCC, CORS e il login code + PKCE;
- account, carrelli salvati, liste dei desideri, punti vendita, resi, assistenza clienti e assisted service;
- B2B: unità, budget, centri di costo, approvazioni degli ordini, preventivi, riordini, PunchOut;
- promozioni, voucher e coupon; bundle, carte regalo, configuratori, abbonamenti;
- OMS e magazzini: sourcing, consegne, processo d’ordine e di reso;
- una Console per catalogo, ordini e clienti, uno Studio per le pagine, un Admin della piattaforma.

È TypeScript su NestJS, con Postgres e Redis. Una app, un container. Si estende con moduli fuori dal core: aggiungi un campo a Product ed è salvato, esposto in OCC, cercabile e modificabile nella Console, senza toccare il core.

## Cosa manca

Dirlo conta più dell’elenco sopra. I prossimi sono i prezzi a righe con tasse e sconti, l’integrazione OData e webhook, l’alta disponibilità e l’SSO del personale. Conosco circa 120 differenze di compatibilità piccole, ognuna tracciata con un piano di test. La [roadmap](https://github.com/mgiuditta/sbu-commerce/blob/main/ROADMAP.md) le ha tutte.

Quindi: compatibile, verificato con uno Spartacus stock, non identico. Non ancora.

## Provalo

```sh
git clone https://github.com/mgiuditta/sbu-commerce.git && cd sbu-commerce
docker compose -f infra/compose/compose.yaml up -d --build --wait
curl 'localhost:3000/occ/v2/electronics/products/search?query=camera'
```

Parte con un catalogo di prova, un sito B2C e uno B2B. Il README spiega come puntarci Spartacus.

## Cosa ti chiedo

Provalo con il tuo storefront, poi [apri una issue](https://github.com/mgiuditta/sbu-commerce/issues) con quello che manca per il tuo caso. È la cosa più utile che puoi fare per il progetto adesso.

---

*Sbu Commerce è un progetto indipendente, senza legami con i produttori delle piattaforme con cui è compatibile.*
