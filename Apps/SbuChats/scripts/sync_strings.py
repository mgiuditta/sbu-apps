"""Builds Apps/SbuChats/SbuChats/Localizable.xcstrings from the compiler's .stringsdata and the
English below. Fails on a key without English; lists English for keys no longer in the code.

xcodebuild doesn't write extracted strings back into the catalog (Xcode does): build once, then
  python3 Apps/SbuChats/scripts/sync_strings.py <derived data path> Apps/SbuChats/SbuChats/Localizable.xcstrings
"""
import glob
import json
import sys

derived, catalog_path = sys.argv[1], sys.argv[2]

EN = {
    "%@": "%@",
    "%@ · %@": "%@ · %@",
    "%lld messaggi, qui i %lld più recenti": "%lld messages, the %lld most recent here",
    "Al": "To",
    "Anno": "Year",
    "Annulla": "Cancel",
    "Apri la chat in WhatsApp e tocca il suo nome in alto.": "Open the chat in WhatsApp and tap its name at the top.",
    "Apri la chat in WhatsApp, tocca ⋮, poi Altro e infine Esporta chat.": "Open the chat in WhatsApp, tap ⋮, then More, then Export chat.",
    "Attività": "Activity",
    "Azioni della chat": "Chat Actions",
    "Cerca nei messaggi": "Search Messages",
    "Chi": "Who",
    "Chi sei?": "Who Are You?",
    "Chiudi": "Close",
    "Come esportare una chat": "How to Export a Chat",
    "Conferma": "Confirm",
    "Conversazioni": "Conversations",
    "Conversazioni chiuse": "Conversations ended",
    "Conversazioni iniziate": "Conversations started",
    "Così i tuoi numeri si separano da quelli degli altri.": "So your numbers stand apart from everyone else's.",
    "Da Android": "From Android",
    "Da iPhone": "From iPhone",
    "Dal": "From",
    "Di chi": "Whose",
    "Elimina": "Delete",
    "Elimina la chat": "Delete Chat",
    "Eliminare “%@”?": "Delete “%@”?",
    "Emoji": "Emoji",
    "Fino all'ultimo messaggio della chat, il %@.": "Up to the chat's last message, on %@.",
    "Foto, video e altri file": "Photos, videos and other files",
    "Giorni con messaggi": "Days with messages",
    "Giorni di fila, record": "Longest streak",
    "Giorno": "Day",
    "Gli altri": "Others",
    "I messaggi e i numeri di questa chat spariscono da Sbu Chats. La chat nell'app di messaggi resta com'è.":
        "This chat's messages and numbers leave Sbu Chats. The chat in your messaging app stays as it is.",
    "Il file non si apre": "The file doesn't open",
    "Il file non va a capo": "The file has no line breaks",
    "Il file è troppo grande": "The file is too large",
    "Il momento più attivo: %@": "Busiest: %@",
    "Il testo supera 200 MB, molto più di qualsiasi chat esportata. Sbu Chats si ferma per non riempire l'iPhone.":
        "The text is over 200 MB, far more than any exported chat. Sbu Chats stops so it doesn't fill your iPhone.",
    "Importa una chat": "Import a Chat",
    "Importazione": "Import",
    "In una chat nuova con uno di questi nomi Sbu Chats sa già chi sei. Scorri a sinistra per dimenticare un nome.":
        "In a new chat with one of these names, Sbu Chats already knows who you are. Swipe left to forget a name.",
    "La chat": "The Chat",
    "La chat resta su questo iPhone. Sbu Chats non si collega a internet, non usa iCloud e non legge altro che i file che gli dai. Puoi eliminare una chat in ogni momento.":
        "The chat stays on this iPhone. Sbu Chats doesn't connect to the internet, doesn't use iCloud and reads nothing but the files you give it. You can delete a chat at any time.",
    "La chat resta su questo iPhone: Sbu Chats non si collega a internet.":
        "The chat stays on this iPhone: Sbu Chats doesn't connect to the internet.",
    "La chat è vuota": "The chat is empty",
    "Le righe del file non iniziano con data e ora come in una chat esportata. Qui sotto c'è la prima riga trovata.":
        "The file's lines don't start with a date and time like an exported chat. The first line found is below.",
    "Le righe hanno data e ora, ma le date non tornano in nessun ordine di giorno, mese e anno. Qui sotto c'è una delle righe.":
        "The lines have a date and time, but the dates don't work in any order of day, month and year. One of the lines is below.",
    "Leggo la chat": "Reading the chat",
    "Lettura": "Reading",
    "Lo ZIP contiene solo foto o altri file, nessun testo della chat. Esporta di nuovo la chat dall'app di messaggi.":
        "The ZIP holds only photos or other files, no chat text. Export the chat again from your messaging app.",
    "Lo ZIP si è interrotto o è protetto da password. Esporta di nuovo la chat, senza comprimerla con altre app.":
        "The ZIP is cut short or protected by a password. Export the chat again, without compressing it with other apps.",
    "Lo ZIP è danneggiato": "The ZIP is damaged",
    "Manda il file all'iPhone, per esempio per email o con un servizio cloud, e aprilo con Sbu Chats.":
        "Send the file to your iPhone, for example by email or a cloud service, and open it with Sbu Chats.",
    "Mese": "Month",
    "Messaggi": "Messages",
    "Messaggi al giorno": "Messages per day",
    "Messaggi per ora del giorno": "Messages by hour of the day",
    "Messaggi per giorno della settimana": "Messages by day of the week",
    "Messaggi per mese": "Messages by month",
    "Messaggi per anno": "Messages by year",
    "Mostra": "Show",
    "Nel colore dell'app i tuoi messaggi, in grigio quelli degli altri. Tocca o trascina sul grafico per leggere una barra.":
        "Your messages in the app's color, everyone else's in grey. Tap or drag on the chart to read a bar.",
    "Nel file non ci sono messaggi scritti da qualcuno, solo avvisi dell'app o nessuna riga.":
        "The file has no messages written by anyone, only app notices or no lines at all.",
    "Nel foglio di condivisione tocca Sbu Chats. Se non c'è, tocca Salva su File e poi, in Sbu Chats, Importa una chat.":
        "In the share sheet, tap Sbu Chats. If it isn't there, tap Save to Files, then Import a Chat in Sbu Chats.",
    "Nell'app di messaggi apri una chat, scegli Esporta chat e condividila con Sbu Chats. Oppure salvala in File e sceglila da qui.":
        "In your messaging app, open a chat, choose Export chat and share it with Sbu Chats. Or save it to Files and choose it from here.",
    "Nello ZIP non c'è una chat": "There's no chat in the ZIP",
    "Nessun messaggio in questo periodo": "No messages in this period",
    "Nessun messaggio nuovo: la chat era già aggiornata": "No new messages: the chat was already up to date",
    "Nessuna chat": "No Chats",
    "Nessuna emoji in questo periodo": "No emoji in this period",
    "Nessuna parola in questo periodo": "No words in this period",
    "Nessuna risposta": "No replies",
    "Nessuno di questi": "None of these",
    "Nome": "Name",
    "Non riconosco il formato": "The format isn't recognized",
    "Non riesco a leggere le date": "The dates can't be read",
    "Nulla è stato importato. Il file resta dov'era.": "Nothing was imported. The file stays where it was.",
    "Ora": "Hour",
    "Parole": "Words",
    "Parole da cercare": "Words to search",
    "Parole ed emoji": "Words and Emoji",
    "Per aggiornare una chat, esportala di nuovo: Sbu Chats aggiunge solo i messaggi nuovi.":
        "To update a chat, export it again: Sbu Chats adds only the new messages.",
    "Periodo": "Period",
    "Personalizzato": "Custom",
    "Persone": "People",
    "Privacy": "Privacy",
    "Prova con una chat di esempio": "Try a Sample Chat",
    "Quando": "When",
    "Quanti messaggi": "How Many Messages",
    "Questo file non è una chat": "This file isn't a chat",
    "Raggruppa per": "Group by",
    "Riga trovata": "Line Found",
    "Rinomina": "Rename",
    "Rinomina la chat": "Rename Chat",
    "Risposta media": "Average reply",
    "Risposta tipica": "Typical reply",
    "Sbu Chats": "Sbu Chats",
    "Sbu Chats legge le chat esportate come .txt o .zip; questo file è .%@.":
        "Sbu Chats reads chats exported as .txt or .zip; this file is .%@.",
    "Sbu Chats non riesce a leggere il file. Esporta di nuovo la chat e condividila con Sbu Chats.":
        "Sbu Chats can't read the file. Export the chat again and share it with Sbu Chats.",
    "Scegli Senza media.": "Choose Without Media.",
    "Scegli Senza media: è più veloce e i numeri sono gli stessi.": "Choose Without Media: it's faster and the numbers are the same.",
    "Scegli chi sei": "Choose Who You Are",
    "Scegli un file": "Choose a File",
    "Scorri in fondo e tocca Esporta chat.": "Scroll to the bottom and tap Export Chat.",
    "Scrivi una o più parole: trovi i messaggi che le contengono tutte. Metti una frase tra virgolette per cercarla esatta, scrivi OR tra due parole per trovare l'una o l'altra.":
        "Type one or more words to find the messages that contain them all. Put a phrase in quotes to find it exactly, type OR between two words to find either.",
    "Sei tu": "You",
    "Senza le parole più comuni della lingua della chat (articoli, preposizioni, pronomi), senza link e numeri.":
        "Without the most common words of the chat's language (articles, prepositions, pronouns), links and numbers.",
    "Scegli il tuo nome: serve a separare i tuoi numeri da quelli degli altri. Sbu Chats lo ricorda per le prossime chat.":
        "Choose your name: it sets your numbers apart from everyone else's. Sbu Chats remembers it for your next chats.",
    "Sull'iPhone, senza internet. Una chat lunga richiede qualche secondo.":
        "On your iPhone, without the internet. A long chat takes a few seconds.",
    "Tocca o trascina sul grafico per leggere una barra. Scegli chi sei per separare i tuoi messaggi.":
        "Tap or drag on the chart to read a bar. Choose who you are to set your messages apart.",
    "Tu": "You",
    "Tu · %@": "You · %@",
    "Tutta la chat": "Whole chat",
    "Tutti": "Everyone",
    "Ultimi 30 giorni": "Last 30 days",
    "Ultimi 6 mesi": "Last 6 months",
    "Ultimo anno": "Last year",
    "Un export contiene al massimo circa 40.000 messaggi senza media o 10.000 con i media, i più recenti: questa chat parte dal %@. Esportala di nuovo più avanti e Sbu Chats aggiunge i messaggi nuovi a questi.":
        "An export holds at most about 40,000 messages without media or 10,000 with media, the most recent ones: this chat starts on %@. Export it again later and Sbu Chats adds the new messages to these.",
    "Un export contiene al massimo circa 40.000 messaggi senza media o 10.000 con i media: i più recenti. Per tenere la storia, esporta di nuovo la stessa chat più avanti: Sbu Chats la riconosce e aggiunge solo i messaggi nuovi.":
        "An export holds at most about 40,000 messages without media or 10,000 with media: the most recent ones. To keep the history, export the same chat again later: Sbu Chats recognizes it and adds only the new messages.",
    "Una conversazione ricomincia dopo 6 ore di silenzio. Le risposte arrivate dopo più di 24 ore non entrano nei tempi di risposta. Messaggi al giorno conta solo i giorni con messaggi.":
        "A conversation starts again after 6 hours of silence. Replies that came more than 24 hours later don't count in reply times. Messages per day counts only days with messages.",
    "Una riga supera 1 MB, più di qualsiasi messaggio: il file non è una chat esportata, o è danneggiato.":
        "A line is over 1 MB, more than any message: the file isn't an exported chat, or it's damaged.",
    "WhatsApp è un marchio di Meta Platforms, Inc. Sbu Chats non è affiliata a Meta.":
        "WhatsApp is a trademark of Meta Platforms, Inc. Sbu Chats is not affiliated with Meta.",
    "alle %@": "%@",
}

# Keys with a count: Italian and English, one and other.
PLURAL = {
    "%lld giorni": (("%lld giorno", "%lld giorni"), ("%lld day", "%lld days")),
    "%lld messaggi": (("%lld messaggio", "%lld messaggi"), ("%lld message", "%lld messages")),
    "Aggiunti %lld messaggi nuovi": (("Aggiunto %lld messaggio nuovo", "Aggiunti %lld messaggi nuovi"), ("Added %lld new message", "Added %lld new messages")),
    "%lld volte": (("%lld volta", "%lld volte"), ("%lld time", "%lld times")),
}


def unit(value):
    return {"stringUnit": {"state": "translated", "value": value}}


def plural(one, other):
    return {"variations": {"plural": {"one": unit(one), "other": unit(other)}}}


keys = set()
for path in glob.glob(f"{derived}/Build/Intermediates.noindex/SbuChats.build/*/SbuChats.build/Objects-normal/*/*.stringsdata"):
    for entries in json.load(open(path)).get("tables", {}).values():
        keys.update(entry["key"] for entry in entries)

missing = sorted(k for k in keys if k not in EN and k not in PLURAL)
stale = sorted(k for k in list(EN) + list(PLURAL) if k not in keys)
if missing:
    sys.exit("No English for:\n  " + "\n  ".join(missing))
if stale:
    print("Not in the code any more (dropped):\n  " + "\n  ".join(stale))

strings = {}
for key in sorted(keys):
    if key in PLURAL:
        (it_one, it_other), (en_one, en_other) = PLURAL[key]
        strings[key] = {"localizations": {"en": plural(en_one, en_other), "it": plural(it_one, it_other)}}
    else:
        strings[key] = {"localizations": {"en": unit(EN[key])}}

with open(catalog_path, "w") as f:
    json.dump({"sourceLanguage": "it", "strings": strings, "version": "1.0"}, f, ensure_ascii=False, indent=2, separators=(",", " : "))
    f.write("\n")
print(f"{len(strings)} strings")
